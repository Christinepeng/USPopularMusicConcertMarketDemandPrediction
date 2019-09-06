library(xlsx)
df <- read.xlsx('../dat/Europe.xlsx', 1)
df$state_ = factor(df$state)

model = lm(ave_price_USD~genre_Alternative+genre_Blues+genre_Classical+genre_Comedy+genre_Country+genre_Dance+genre_Folk+genre_HipHop_Rap+genre_Jazz+genre_Latin+genre_Pop+genre_RnB_Soul+genre_Rock_Metal+genre_Other+state_+genre_Alternative:state_+genre_Blues:state_+genre_Classical:state_+genre_Comedy:state_+genre_Country:state_+genre_Dance:state_+genre_Folk:state_+genre_HipHop_Rap:state_+genre_Jazz:state_+genre_Latin:state_+genre_Pop:state_+genre_RnB_Soul:state_+genre_Rock_Metal:state_+genre_Other:state_+genre_Alternative:sold_out_80+genre_Blues:sold_out_80+genre_Classical:sold_out_80+genre_Comedy:sold_out_80+genre_Country:sold_out_80+genre_Dance:sold_out_80+genre_Folk:sold_out_80+genre_HipHop_Rap:sold_out_80+genre_Jazz:sold_out_80+genre_Latin:sold_out_80+genre_Pop:sold_out_80+genre_RnB_Soul:sold_out_80+genre_Rock_Metal:sold_out_80+genre_Other:sold_out_80+state_:sold_out_80+genre_Alternative:state_:sold_out_80+genre_Blues:state_:sold_out_80+genre_Classical:state_:sold_out_80+genre_Comedy:state_:sold_out_80+genre_Country:state_:sold_out_80+genre_Dance:state_:sold_out_80+genre_Folk:state_:sold_out_80+genre_HipHop_Rap:state_:sold_out_80+genre_Jazz:state_:sold_out_80+genre_Latin:state_:sold_out_80+genre_Pop:state_:sold_out_80+genre_RnB_Soul:state_:sold_out_80+genre_Rock_Metal:state_:sold_out_80+genre_Other:state_:sold_out_80+sold_out_80:capacity, data=df)

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
