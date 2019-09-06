library(xlsx)
df <- read.xlsx('../dat/USA.xlsx', 1)
df$state_f_ = factor(df$state)

model = lm(
    ave_price_USD
    ~genre_Alternative
    +genre_Blues
    +genre_Classical
    +genre_Comedy
    +genre_Country
    +genre_Dance
    +genre_Folk
    +genre_HipHop_Rap
    +genre_Jazz
    +genre_Latin
    +genre_Pop
    +genre_RnB_Soul
    +genre_Rock_Metal
    +genre_Other
    +state_f_
    +genre_Alternative:state_f_
    +genre_Blues:state_f_
    +genre_Classical:state_f_
    +genre_Comedy:state_f_
    +genre_Country:state_f_
    +genre_Dance:state_f_
    +genre_Folk:state_f_
    +genre_HipHop_Rap:state_f_
    +genre_Jazz:state_f_
    +genre_Latin:state_f_
    +genre_Pop:state_f_
    +genre_RnB_Soul:state_f_
    +genre_Rock_Metal:state_f_
    +genre_Other:state_f_
    +genre_Alternative:sold_out_80
    +genre_Blues:sold_out_80
    +genre_Classical:sold_out_80
    +genre_Comedy:sold_out_80
    +genre_Country:sold_out_80
    +genre_Dance:sold_out_80
    +genre_Folk:sold_out_80
    +genre_HipHop_Rap:sold_out_80
    +genre_Jazz:sold_out_80
    +genre_Latin:sold_out_80
    +genre_Pop:sold_out_80
    +genre_RnB_Soul:sold_out_80
    +genre_Rock_Metal:sold_out_80
    +genre_Other:sold_out_80
    +state_f_:sold_out_80
    +genre_Alternative:state_f_:sold_out_80
    +genre_Blues:state_f_:sold_out_80
    +genre_Classical:state_f_:sold_out_80
    +genre_Comedy:state_f_:sold_out_80
    +genre_Country:state_f_:sold_out_80
    +genre_Dance:state_f_:sold_out_80
    +genre_Folk:state_f_:sold_out_80
    +genre_HipHop_Rap:state_f_:sold_out_80
    +genre_Jazz:state_f_:sold_out_80
    +genre_Latin:state_f_:sold_out_80
    +genre_Pop:state_f_:sold_out_80
    +genre_RnB_Soul:state_f_:sold_out_80
    +genre_Rock_Metal:state_f_:sold_out_80
    +genre_Other:state_f_:sold_out_80
    +sold_out_80:capacity, 
    data=df
)







'''
x <- summary(model)
arr = c(0, 0.001, 0.01, 0.05)
for (idx in 1:(length(arr)-1)) {
    lb = arr[idx]
    rb = arr[idx+1]
    to_select <- lb < x$coeff[-1,4] & x$coeff[-1,4] <= rb
    relevant <- names(to_select)[to_select==TRUE]
    print(c(lb, rb))
    print(x$coeff[-1,1][relevant])
}
print(x$r.squared)
print(x$adj.r.squared)
'''


library(dplyr)
library(broom)
options(tibble.print_max = Inf)


# set month_f_ as categorical feature
df$month_f_ = factor(df$month)


# number of features (31 - 1 + 12)
num_features = 42


# number of data by state
state_df_num = df %>% 
    group_by(state) %>%
    summarise(num = n())
write.csv(state_df_num, "../res/state_num.csv", row.names=FALSE)


# state model 
state_df_model = df %>%
    group_by(state) %>%
    filter(n() >= num_features) %>%
    do(state_model = lm(ave_price_USD~genre_Alternative+genre_Blues+genre_Classical+genre_Comedy+genre_Country+genre_Dance+genre_Folk+genre_HipHop_Rap+genre_Jazz+genre_Latin+genre_Pop+genre_RnB_Soul+genre_Rock_Metal+genre_Other+genre_Alternative:sold_out_80+genre_Blues:sold_out_80+genre_Classical:sold_out_80+genre_Comedy:sold_out_80+genre_Country:sold_out_80+genre_Dance:sold_out_80+genre_Folk:sold_out_80+genre_HipHop_Rap:sold_out_80+genre_Jazz:sold_out_80+genre_Latin:sold_out_80+genre_Pop:sold_out_80+genre_RnB_Soul:sold_out_80+genre_Rock_Metal:sold_out_80+genre_Other:sold_out_80+sold_out_80, data=.))
    #do(state_model = lm(ave_price_USD~genre_Alternative+genre_Blues+genre_Classical+genre_Comedy+genre_Country+genre_Dance+genre_Folk+genre_HipHop_Rap+genre_Jazz+genre_Latin+genre_Pop+genre_RnB_Soul+genre_Rock_Metal+genre_Other+genre_Alternative:sold_out_80+genre_Blues:sold_out_80+genre_Classical:sold_out_80+genre_Comedy:sold_out_80+genre_Country:sold_out_80+genre_Dance:sold_out_80+genre_Folk:sold_out_80+genre_HipHop_Rap:sold_out_80+genre_Jazz:sold_out_80+genre_Latin:sold_out_80+genre_Pop:sold_out_80+genre_RnB_Soul:sold_out_80+genre_Rock_Metal:sold_out_80+genre_Other:sold_out_80+sold_out_80:capacity, data=.))

state_df_coef = tidy(state_df_model, state_model)
state_df_summary = glance(state_df_model, state_model)

print(c("feasible states:", state_df_summary$state))

write.csv(state_df_coef, "../res/state_coef.csv", row.names=FALSE)
write.csv(state_df_summary, "../res/state_summary.csv", row.names=FALSE)


# chi-square between state and genre
col_names = colnames(df)
genre_prefix_list = col_names[grepl("^genre_", col_names)]
new_col_names = col_names[!(col_names %in% genre_prefix_list)]
genre_col_names = c(new_col_names, "genre_type")

genre_df = data.frame(matrix(ncol=length(genre_col_names), nrow=0))
colnames(genre_df) = genre_col_names
for (genre_prefix in genre_prefix_list) {
    genre_df = rbind(genre_df, data.frame(df[df[genre_prefix] == 1, new_col_names], genre_type=genre_prefix))
}

g_model = lm(ave_price_USD~genre_f_+state_f_+genre_f_:state_f_+genre_f_:sold_out_80+state_f_:sold_out_80+genre_f_:state_f_:sold_out_80+sold_out_80:capacity, data=genre_df)
             genre_Alternative+genre_Blues+genre_Classical+genre_Comedy+genre_Country+genre_Dance+genre_Folk+genre_HipHop_Rap+genre_Jazz+genre_Latin+genre_Pop+genre_RnB_Soul+genre_Rock_Metal+genre_Other+state_f_+genre_Alternative:state_f_+genre_Blues:state_f_+genre_Classical:state_f_+genre_Comedy:state_f_+genre_Country:state_f_+genre_Dance:state_f_+genre_Folk:state_f_+genre_HipHop_Rap:state_f_+genre_Jazz:state_f_+genre_Latin:state_f_+genre_Pop:state_f_+genre_RnB_Soul:state_f_+genre_Rock_Metal:state_f_+genre_Other:state_f_+genre_Alternative:sold_out_80+genre_Blues:sold_out_80+genre_Classical:sold_out_80+genre_Comedy:sold_out_80+genre_Country:sold_out_80+genre_Dance:sold_out_80+genre_Folk:sold_out_80+genre_HipHop_Rap:sold_out_80+genre_Jazz:sold_out_80+genre_Latin:sold_out_80+genre_Pop:sold_out_80+genre_RnB_Soul:sold_out_80+genre_Rock_Metal:sold_out_80+genre_Other:sold_out_80+state_f_:sold_out_80+genre_Alternative:state_f_:sold_out_80+genre_Blues:state_f_:sold_out_80+genre_Classical:state_f_:sold_out_80+genre_Comedy:state_f_:sold_out_80+genre_Country:state_f_:sold_out_80+genre_Dance:state_f_:sold_out_80+genre_Folk:state_f_:sold_out_80+genre_HipHop_Rap:state_f_:sold_out_80+genre_Jazz:state_f_:sold_out_80+genre_Latin:state_f_:sold_out_80+genre_Pop:state_f_:sold_out_80+genre_RnB_Soul:state_f_:sold_out_80+genre_Rock_Metal:state_f_:sold_out_80+genre_Other:state_f_:sold_out_80+sold_out_80:capacity, data=df)

genre_df_mean = genre_df %>%
    group_by(state, genre_type) %>%
    summarise(mean = mean(ave_price_USD))

library(reshape2)
state_genre = dcast(genre_df_mean, state~genre_type)
state_genre_drop = state_genre[, -which(genre_prefix_list %in% c("genre_Classical", "genre_Comedy", "genre_Latin", "genre_Other"))]
state_genre_complete = state_genre_drop[complete.cases(state_genre_drop),]
rownames(state_genre_complete) = state_genre_complete$state
state_genre_final = state_genre_complete[, -which(colnames(state_genre_complete) %in% "state")]
print(chisq.test(state_genre_final))
