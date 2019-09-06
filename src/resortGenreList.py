from cStringIO import StringIO
import argparse
import re
import yaml


def _fix_dump(dump, indentSize=4):
    stream = StringIO(dump)
    out = StringIO()
    pat = re.compile('(\s*)([^:]*)(:*)')
    last = None

    prefix = 0
    for s in stream:
        indent, key, colon = pat.match(s).groups()
        if indent=="" and key[0]!= '-':
            prefix = 0
        if last:
            if len(last[0])==len(indent) and last[2]==':':
                if all([
                        not last[1].startswith('-'),
                        s.strip().startswith('-')
                        ]):
                    prefix += indentSize
        out.write(" "*prefix+s)
        last = indent, key, colon
    return out.getvalue()


parser = argparse.ArgumentParser(description='Resort the order of given genre yaml file')
parser.add_argument('genre_file_name', type=str, nargs='?', default='../dat/genre_v2.yaml', help='Path of a genre file to be resorted')
args = parser.parse_args()
genre_file_name = args.genre_file_name


genre_dict = yaml.load(open(genre_file_name))
for key, value in genre_dict.iteritems():
    value.sort()
with open(genre_file_name, 'w') as wf:
    wf.write(_fix_dump(yaml.dump(genre_dict, default_flow_style=False)))
