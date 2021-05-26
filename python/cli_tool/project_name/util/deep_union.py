def deep_dict_union(original_dict, override_dict):
    for k,v in override_dict.items():
        if k in original_dict:
            if isinstance(original_dict[k],dict) and isinstance(v,dict):
                original_dict[k] = deep_dict_union(original_dict[k], v)
                continue
        original_dict[k] = v
    return original_dict
