import pandas as pd


xl = pd.ExcelFile('../dat/USA_with_promoters.xlsx')
origin_df = xl.parse('origin')
promoter_df = xl.parse('promoter')

df = pd.merge(origin_df, promoter_df, on=['Headline Artist/Band/Event', 'Capacity', 'Percentage'])
df['b_promoter'] = df['Promoter(s)'].str.contains('(In-House Promotion)').astype(int)

df.to_excel('../dat/USA_merge_promoters.xlsx', sheet_name='USA', index=False)
