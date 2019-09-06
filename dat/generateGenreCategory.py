from collections import defaultdict
import re
import yaml


genre_yaml = '../dat/genre_v0.yaml'
spotify_genre = '../dat/spotify_genre.bak'
new_genre_yaml = '../dat/genre_v1.yaml'


# read from genre.yaml (approximates from spotify genre)
genre_dict = yaml.load(open(genre_yaml))

# read from text file
with open(spotify_genre) as f:
    lines = map(lambda line: line.strip(), f.readlines())

# start matching
new_genre_dict = defaultdict(list)
c_match_pattern_template = '^(.*[\ -])*{}([\ -].*)*$' 
p_match_pattern_template = '^.*{}.*$' 
for line in sorted(lines):
    at_least_one_genre_match = False
    for genre_name, genre_pattern in genre_dict.iteritems():
        match_flag = False

        # complete match
        for c_genre_pattern in genre_pattern['complete']:
            c_match = re.match(c_match_pattern_template.format(c_genre_pattern), line)
            if c_match:
                match_flag = True
        
        # partial match
        for p_genre_pattern in genre_pattern['partial']:
            p_match = re.match(p_match_pattern_template.format(p_genre_pattern), line)
            if p_match:
                match_flag = True

        if match_flag:
            new_genre_dict[genre_name].append(line)
            at_least_one_genre_match = True
    # if match_flag is True, add genre 
    if not at_least_one_genre_match:
        new_genre_dict['other'].append(line)

# write new genre file
with open(new_genre_yaml, 'w') as wf:
    yaml.dump(dict(new_genre_dict), wf, default_flow_style=False)
