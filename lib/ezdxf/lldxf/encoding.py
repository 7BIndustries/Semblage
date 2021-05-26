# Copyright (c) 2016-2020, Manfred Moitzi
# License: MIT License
import re
import codecs

surrogate_escape = codecs.lookup_error('surrogateescape')
BACKSLASH_UNICODE = re.compile(r'(\\U\+[A-F0-9]{4})')


def dxf_backslash_replace(exc: Exception):
    if isinstance(exc, (UnicodeEncodeError, UnicodeTranslateError)):
        s = ""
        for c in exc.object[exc.start:exc.end]:
            x = ord(c)
            if x <= 0xff:
                s += "\\x%02x" % x
            elif 0xdc80 <= x <= 0xdcff:
                # Delegate surrogate handling:
                return surrogate_escape(exc)
            elif x <= 0xffff:
                s += "\\U+%04x" % x
            else:
                s += "\\U+%08x" % x
        return s, exc.end
    else:
        raise TypeError(f"Can't handle {exc.__class__.__name__}")


def encode(s: str, encoding='utf8') -> bytes:
    """ Shortcut to use the correct error handler """
    return s.encode(encoding, errors='dxfreplace')


def _decode(s: str) -> str:
    if s.startswith(r'\U+'):
        return chr(int(s[3:], 16))
    else:
        return s


def has_dxf_unicode(s: str) -> bool:
    r""" Detect if string `s` contains encoded DXF unicode characters "\\U+xxxx".
    """
    return bool(re.search(BACKSLASH_UNICODE, s))


def decode_dxf_unicode(s: str) -> str:
    r""" Decode DXF unicode characters "\\U+xxxx" in string `s`. """

    return ''.join(_decode(part) for part in re.split(BACKSLASH_UNICODE, s))
