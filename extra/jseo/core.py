import triton.language.core as tl

@tl.builtin
def load(
    ptr,
    mask = None,
    other = None,
    boundary_check = (),
    padding_option = "",
    cache_modifier = "",
    evict_policy = "",
    volatile = False,
    _semantic=None,
    dep = "rw",
) -> tl.tensor:
    ...