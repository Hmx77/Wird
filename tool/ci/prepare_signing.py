"""Read GitHub environment secrets without printing them; never generate keys."""
import base64
import os
from pathlib import Path


def properties_escape(value):
    # Java Properties.load(InputStream) uses ISO-8859-1 and backslash escapes.
    output = ''
    for char in value:
        code = ord(char)
        if char in '\\:=#! ':
            output += '\\' + char
        elif char == '\n':
            output += '\\n'
        elif char == '\r':
            output += '\\r'
        elif code > 126 or code < 32:
            for i in range(0, len(char.encode('utf-16-be')), 2):
                unit = char.encode('utf-16-be')[i:i + 2]
                output += '\\u' + unit.hex()
        else:
            output += char
    return output


def main():
    names = ['WIRD_KEYSTORE_BASE64', 'WIRD_STORE_PASSWORD', 'WIRD_KEY_PASSWORD', 'WIRD_KEY_ALIAS']
    values = {name: os.environ.get(name, '') for name in names}
    if not all(values.values()):
        raise SystemExit('Signing secrets are missing. No release artifact will be built.')
    try:
        data = base64.b64decode(values['WIRD_KEYSTORE_BASE64'], validate=True)
    except ValueError:
        raise SystemExit('Invalid keystore encoding; no secret content logged.') from None
    if not data:
        raise SystemExit('Empty keystore; no release artifact will be built.')
    os.umask(0o077)
    keystore = Path(os.environ['RUNNER_TEMP']) / 'wird-upload.jks'
    keystore.write_bytes(data)
    props = {'storeFile': str(keystore), 'storePassword': values['WIRD_STORE_PASSWORD'],
             'keyPassword': values['WIRD_KEY_PASSWORD'], 'keyAlias': values['WIRD_KEY_ALIAS']}
    Path('android/key.properties').write_text(''.join(
        f'{key}={properties_escape(value)}\n' for key, value in props.items()), encoding='ascii')
    print('Existing signing material prepared in temporary private files.')


if __name__ == '__main__':
    main()
