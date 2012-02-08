def safe_file_name(s):
    '''
    '''
    ok = string.ascii_letters + string.digits + "_"
    new_str = ''
    for char in s:
        if char not in ok:
            new_str += "_"
        else:
            new_str += char
    return new_str
