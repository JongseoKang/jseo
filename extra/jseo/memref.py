import triton.language as tl
import triton.language.core as core
# from triton.language.core import _builder

@core.extern
def load(
    ptr,
    mask = None,
    other = None,
    # boundary_check = (),
    # padding_option = "",
    # cache_modifier = "",
    # evict_policy = "",
    # volatile = False,
    dep = "rw",
    _semantic = None,
):
    '''Now only support mask/other loading.'''
    # `mask` and `other` can be constexpr
    # mask = core._constexpr_to_value(mask)
    # other = core._constexpr_to_value(other)
    _builder = _semantic.builder
    func = f"jseo_load_{dep}_"
    
    print(f"ptr type: {type(ptr)}")
    if mask is not None:
        mask = _semantic.to_tensor(mask, _builder)
    if other is not None:
        other = _semantic.to_tensor(other, _builder)
    
    
    if not ptr.type.scalar.is_ptr():
        raise ValueError(f"Unsupported ptr type {ptr.type.__repr__()} in `jseo.load`")

    # Check `mask` and `other` arguments
    if mask is None and other is not None:
        raise ValueError("`other` cannot be provided without `mask`")
    # For a pointer of scalar, check the type of `mask` and `other`
    if not ptr.type.is_block():
        if mask and mask.type.is_block():
            raise ValueError("Mask argument cannot be block type if pointer argument is not a block")
        if other and other.type.is_block():
            raise ValueError("Other argument cannot be block type if pointer argument is not a block")

    # Make `mask` and `other` into the same shape as `ptr`
    print(f"ptr type: {type(ptr.type)}")
    if ptr.type.is_block():
        if mask is not None:
            mask = _semantic.broadcast_impl_shape(mask, ptr.type.get_block_shapes())
        if other is not None:
            other = _semantic.broadcast_impl_shape(other, ptr.type.get_block_shapes())

    # Get `pointer_type<elt_ty>` and `elt_ty`
    ptr_ty = ptr.type.scalar
    elt_ty = ptr_ty.element_ty

    # Treat `pointer_type<tl.int1>` as `pointer_type<tl.int8>`
    is_bool = elt_ty == core.int1
    if is_bool:
        elt_ty = core.int8
        ptr_ty = core.pointer_type(elt_ty, ptr_ty.address_space)
        ptr = _semantic.cast(ptr, ptr_ty)

    # Cast `other` into `elt_ty` type
    if other is not None:
        other = _semantic.cast(other, elt_ty)

    # Create loaded result type `dst_ty`
    if ptr.type.is_block():
        dst_ty = ptr.type.with_element_ty(elt_ty)
    else:
        # Load by de-referencing the pointer of scalar
        dst_ty = elt_ty
    
    dst_ty_handle = dst_ty.to_ir(_builder)
    print(type(dst_ty))
    
    if mask is not None and other is not None:
        func += "masked"
        return core.tensor(_builder.create_extern_elementwise("", "", func,
                                                  [ptr.handle, mask.handle, other.handle],
                                                  dst_ty_handle, True),
                         dst_ty)
    else:
        func += "unmasked"
        return core.tensor(_builder.create_extern_elementwise("", "", func, 
                                       [ptr.handle],
                                       dst_ty_handle, True),
                         dst_ty)