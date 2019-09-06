import openpyxl
import yaml


date = '06182018'

input_xlsx = '../dat/{}_raw.xlsx'.format(date)
genre_yaml = '../dat/genre_v2.yaml'
output_xlsx = '../res/{}_new.xlsx'.format(date)


# read from old workbook
input_wb = openpyxl.load_workbook(filename = input_xlsx)
input_ws = input_wb['Genre']

# read from genre.yaml (approximates from spotify genre)
genre_dict = yaml.load(open(genre_yaml))

# write to new workbook
output_wb = openpyxl.Workbook()
output_ws = output_wb.active
output_ws.title = 'Genre'
output_ws.append(['origin_artist_name', 'found_artist_name', 'number_of_genres'])

exceptions = set()
for row in list(input_ws.rows)[1:]:
    origin_artist_name = row[0].value
    found_artist_name = row[1].value
    number_of_genres = row[2].value
    genre_res_set = set()

    if number_of_genres == 'NULL':
        assert found_artist_name == 'NULL'
    else:
        # go through all listed genres in row
        for idx in range(3, 3+number_of_genres):
            at_least_one_genre = False
            for genre_name, genre_patterns in genre_dict.iteritems():
                if row[idx].value in genre_patterns:
                    genre_res_set.add(genre_name)
                    at_least_one_genre = True
            if not at_least_one_genre:
                exceptions.add(str(row[idx].value))
    data = [origin_artist_name, found_artist_name, len(genre_res_set)] + sorted(genre_res_set)
    output_ws.append(data)

output_wb.save(output_xlsx)
print 'Uncategorized genres:'
print yaml.dump(list(exceptions), default_flow_style=False)
