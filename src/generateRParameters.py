genre_name_list = ['genre_Alternative', 'genre_Blues', 'genre_Classical', 'genre_Comedy', 'genre_Country', 'genre_Dance', 'genre_Folk', 'genre_HipHop_Rap', 'genre_Jazz', 'genre_Latin', 'genre_Pop', 'genre_RnB_Soul', 'genre_Rock_Metal', 'genre_Other']
#region_name_list = ['region_Alaska', 'region_Alabama', 'region_Arkansas', 'region_Arizona', 'region_California', 'region_Colorado', 'region_Connecticut', 'region_WashingtonDC', 'region_Delaware', 'region_Florida', 'region_Georgia', 'region_Hawaii', 'region_Iowa', 'region_Idaho', 'region_Illinois', 'region_Indiana', 'region_Kansas', 'region_Kentucky', 'region_Louisiana', 'region_Massachusetts', 'region_Maryland', 'region_Maine', 'region_Michigan', 'region_Minnesota', 'region_Missouri', 'region_Mississippi', 'region_Montana', 'region_North_Carolina', 'region_North_Dakota', 'region_Nebraska', 'region_New_Hampshire', 'region_New_Jersey', 'region_New_Mexico', 'region_Nevada', 'region_New_York', 'region_Ohio', 'region_Oklahoma', 'region_Oregon', 'region_Pennsylvania', 'region_PuertoRico', 'region_Rhode_Island', 'region_South_Carolina', 'region_South_Dakota', 'region_Tennessee', 'region_Texas', 'region_Utah', 'region_Virginia', 'region_Vermont', 'region_Washington', 'region_Wisconsin', 'region_West_Virginia', 'region_Wyoming']
#region_name_list = ['region_Austria', 'region_Belarus', 'region_Belgium', 'region_Croatia', 'region_Czech', 'region_Denmark', 'region_Estonia', 'region_Finland', 'region_France', 'region_Germany', 'region_Greece', 'region_Hungary', 'region_Ireland', 'region_Italy', 'region_Lithuania', 'region_Luxembourg', 'region_Macedonia', 'region_Netherlands', 'region_Norway', 'region_Poland', 'region_Portugal', 'region_Romania', 'region_Slovenia', 'region_Spain', 'region_Sweden', 'region_Switzerland', 'region_Turkey', 'region_Ukraine', 'region_United', 'region_Slovak']
region_name_list = ['state_abbr_f']
sold_out_name_list = ['sold_out_80']
capacity_name_list = ['capacity']

output_list = []

# genre only
for genre_name in genre_name_list:
    output_list.append(genre_name)

# region only
'''
for region_name in region_name_list:
    output_list.append(region_name)
'''

# genre + region
'''
for genre_name in genre_name_list:
    for region_name in region_name_list:
        output_list.append('*'.join([genre_name, region_name]))
'''

# genre + sold_out
for genre_name in genre_name_list:
    for sold_out_name in sold_out_name_list:
        output_list.append('*'.join([genre_name, sold_out_name]))

# region + sold_out
'''
for region_name in region_name_list:
    for sold_out_name in sold_out_name_list:
        output_list.append('*'.join([region_name, sold_out_name]))
'''

# genre + region + sold_out
'''
for genre_name in genre_name_list:
    for region_name in region_name_list:
        for sold_out_name in sold_out_name_list:
            output_list.append('*'.join([genre_name, region_name, sold_out_name]))
'''

# sold_out + capacity
for sold_out_name in sold_out_name_list:
    for capacity_name in capacity_name_list:
        output_list.append('*'.join([sold_out_name, capacity_name]))

print '+'.join(output_list)
