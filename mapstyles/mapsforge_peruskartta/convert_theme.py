import xml.etree.ElementTree as ET
import sys

def scale_float(value, divisor=2.5):
    """Scales values that are allowed to be decimals (e.g. stroke-width)."""
    try:
        float_val = float(value)
        new_val = float_val / divisor
        # Return formatted string, removing trailing zeros (2.0 -> 2)
        return "{:g}".format(new_val)
    except ValueError:
        return value

def scale_int(value, divisor=2.5):
    """Scales values that MUST be integers (e.g. symbol dimensions). Rounds to nearest."""
    try:
        float_val = float(value)
        # Scale and round to nearest whole number
        new_val = int(round(float_val / divisor))
        # Ensure we don't scale down to 0, which might make symbols disappear
        if new_val == 0 and float_val > 0:
            new_val = 1
        return str(new_val)
    except ValueError:
        return value

def transform_theme(input_file, output_file):
    ET.register_namespace('', "http://mapsforge.org/renderTheme")
    
    try:
        tree = ET.parse(input_file)
        root = tree.getroot()
    except ET.ParseError as e:
        print(f"Error parsing XML: {e}")
        return

    # 1. Update Root Version
    if root.get('version'):
        root.set('version', '4')

    # Attributes that allow DECIMALS
    float_attributes = [
        'stroke-width',
        'radius',
        'dy',
        'font-size' 
    ]

    # Attributes that require INTEGERS
    int_attributes = [
        'symbol-width',
        'symbol-height',
        'repeat-gap',
        'repeat-start',
        'width',       # pattern width
        'height',      # pattern height
        'priority',    # usually int, strictly
        'z-index'
    ]

    for elem in root.iter():
        
        # 2. Syntax Fixes
        if elem.tag.endswith('lineSymbol'):
            if elem.get('align-center') == 'true':
                del elem.attrib['align-center']
                elem.set('position', 'center')

        if elem.tag.endswith('circle'):
            if 'scale-radius' in elem.attrib:
                del elem.attrib['scale-radius']

        # 3. Apply Scaling
        for attr in list(elem.attrib): # List copy to avoid modification issues
            if attr in float_attributes:
                elem.attrib[attr] = scale_float(elem.attrib[attr])
            elif attr in int_attributes:
                elem.attrib[attr] = scale_int(elem.attrib[attr])

    tree.write(output_file, encoding='utf-8', xml_declaration=True)
    print(f"Transformation complete. Saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_theme_v2.py <input_file.xml> <output_file.xml>")
    else:
        transform_theme(sys.argv[1], sys.argv[2])