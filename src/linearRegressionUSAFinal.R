# install.packages("broom")
# install.packages("dplyr")
# install.packages("fiftystater")
# install.packages("ggplot2")
# install.packages("mapproj")
# install.packages("stringr")
# install.packages("xlsx")
library(broom)
library(dplyr)
library(fiftystater)
library(ggplot2)
library(mapproj)
library(stringr)
library(xlsx)


# read data
df <- read.xlsx('../dat/USA_merge_promoters.xlsx', 1)

# remove fake state: "PuertoRico" and "Washington, D.C"
df <- df [(!(df$state=="PuertoRico") & !(df$state=="Washington, D.C.")),]

# factorize categorical data
df$state_f_ = factor(df$state)
df$month_f_ = factor(df$month)
df$day_f_ = factor(df$day)

# set "California" as the basis for state
df$state_f_ <- relevel(df$state_f_, "California")

# learn model
model = lm(
    ave_price_USD
    ~genre_Alternative
    +genre_Blues
    +genre_Country
    +genre_Dance
    +genre_Electronic
    +genre_Folk
    +genre_HipHop_Rap
    +genre_Jazz
    +genre_Pop
    +genre_RnB_Soul
    +genre_Rock_Metal
    +genre_Other
    +state_f_
    +genre_Alternative:state_f_
    +genre_Blues:state_f_
    +genre_Country:state_f_
    +genre_Dance:state_f_
    +genre_Electronic:state_f_
    +genre_Folk:state_f_
    +genre_HipHop_Rap:state_f_
    +genre_Jazz:state_f_
    +genre_Pop:state_f_
    +genre_RnB_Soul:state_f_
    +genre_Rock_Metal:state_f_
    +genre_Other:state_f_
    +genre_Alternative:sold_out_80
    +genre_Blues:sold_out_80
    +genre_Country:sold_out_80
    +genre_Dance:sold_out_80
    +genre_Electronic:sold_out_80
    +genre_Folk:sold_out_80
    +genre_HipHop_Rap:sold_out_80
    +genre_Jazz:sold_out_80
    +genre_Pop:sold_out_80
    +genre_RnB_Soul:sold_out_80
    +genre_Rock_Metal:sold_out_80
    +genre_Other:sold_out_80
    +state_f_:sold_out_80
    +genre_Alternative:state_f_:sold_out_80
    +genre_Blues:state_f_:sold_out_80
    +genre_Country:state_f_:sold_out_80
    +genre_Dance:state_f_:sold_out_80
    +genre_Electronic:state_f_:sold_out_80
    +genre_Folk:state_f_:sold_out_80
    +genre_HipHop_Rap:state_f_:sold_out_80
    +genre_Jazz:state_f_:sold_out_80
    +genre_Pop:state_f_:sold_out_80
    +genre_RnB_Soul:state_f_:sold_out_80
    +genre_Rock_Metal:state_f_:sold_out_80
    +genre_Other:state_f_:sold_out_80
    +sold_out_80:Capacity
    +month_f_
    +day_f_
    +youtube_count_ln
    +b_promoter,
    data=df
)

# model performance
print(sprintf("R-Squared: %f; Adjust R-Squared: %f", summary(model)$r.squared, summary(model)$adj.r.squared))
weights = summary(model)$coefficients[,1]
stderrs = summary(model)$coefficients[,2]
pvalues = summary(model)$coefficients[,4]
stars = symnum(pvalues, corr = FALSE, na = FALSE, cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), symbols = c("***", "**", "*", ".", " "))
feature_df = data.frame(feature_names=names(pvalues), weights=weights, stderrs=stderrs, pvalues=pvalues, stars=stars, row.names=NULL)
write.table(feature_df, '../res/feature_importance.txt', quote=FALSE, sep=',', row.names=F)


# patterns
predictor_names = names(model$coeff)
gerne_name_list = grep("^genre_[^:]*$", predictor_names, value=TRUE)
state_name_list = grep("^state_f_[^:]*$", predictor_names, value=TRUE) 
soldout_name = "sold_out_80"

# Case 0: sold_out_80 == 0
for (genre_name in gerne_name_list) {
    std_genre_name = tolower(substring(genre_name, 7))
    print(sprintf("Now is working on %s", std_genre_name))

    { # special case for California
        std_state_name = "california"
        state_ave_price_df = data.frame(
            state = std_state_name, 
            ave_price = model$coeff[genre_name]
        )
    }
    for (state_name in state_name_list) {
        std_state_name = tolower(substring(state_name, 9))
        state_ave_price_df = rbind(state_ave_price_df, data.frame(
            state = std_state_name, 
            ave_price = model$coeff[genre_name]
                        + model$coeff[sprintf("%s:%s", genre_name, state_name)]
        ))
    }

    # fix price
    # state_ave_price_df[is.na(state_ave_price_df$ave_price), "ave_price"] = 0

    #scale_fill_continuous(high = "#132B43", low = "#56B1F7")
    p = ggplot(state_ave_price_df, aes(map_id = state)) +
        geom_map(aes(fill = ave_price), map = fifty_states) +
        expand_limits(x = fifty_states$long, y = fifty_states$lat) +
        coord_map() +
        scale_x_continuous(breaks = NULL) +
        scale_y_continuous(breaks = NULL) +
        scale_fill_gradientn(limits=c(-150, +150), colours=c("palevioletred4", "gainsboro", "royalblue4")) +
        # ggtitle(sprintf("Average Ticket Price for Genre:%s in United States (when present ratio < 0.8)", std_genre_name)) +
        labs(x = "", y = "") +
        theme(legend.position = "bottom", panel.background = element_blank(), legend.title=element_blank()) +
        fifty_states_inset_boxes()

    print(sprintf("Min: %f; Max: %f", min(state_ave_price_df$ave_price, na.rm=T), max(state_ave_price_df$ave_price, na.rm=T)))
    ggsave(sprintf("../res/wo_soldout/map_us_%s.png", std_genre_name), plot=p, width=10, height=6)
}

# Case 1: sold_out_80 == 1
for (genre_name in gerne_name_list) {
    std_genre_name = tolower(substring(genre_name, 7))
    print(sprintf("Now is working on %s", std_genre_name))

    { # special case for California
        std_state_name = "california"
        state_ave_price_df = data.frame(
            state = std_state_name, 
            ave_price = model$coeff[genre_name]
                        + model$coeff[sprintf("%s:%s", genre_name, soldout_name)]
        )
    }
    for (state_name in state_name_list) {
        std_state_name = tolower(substring(state_name, 9))
        state_ave_price_df = rbind(state_ave_price_df, data.frame(
            state = std_state_name,
            ave_price = model$coeff[genre_name]
                        + model$coeff[sprintf("%s:%s", genre_name, state_name)]
                        + model$coeff[sprintf("%s:%s", genre_name, soldout_name)]
                        + model$coeff[sprintf("%s:%s:%s", genre_name, state_name, soldout_name)]
        ))
    }

    # fix price
    # state_ave_price_df[is.na(state_ave_price_df$ave_price), "ave_price"] = 0

    #scale_fill_continuous(high = "#132B43", low = "#56B1F7")
    p = ggplot(state_ave_price_df, aes(map_id = state)) +
        geom_map(aes(fill = ave_price), map = fifty_states) +
        expand_limits(x = fifty_states$long, y = fifty_states$lat) +
        coord_map() +
        scale_x_continuous(breaks = NULL) +
        scale_y_continuous(breaks = NULL) +
        scale_fill_gradientn(limits=c(-150, +150), colours=c("palevioletred4", "gainsboro", "royalblue4")) +
        # ggtitle(sprintf("Average Ticket Price for Genre:%s in United States (when present ratio >= 0.8)", std_genre_name)) +
        labs(x = "", y = "") +
        theme(legend.position = "bottom", panel.background = element_blank(), legend.title=element_blank()) +
        fifty_states_inset_boxes()

    print(sprintf("Min: %f; Max: %f", min(state_ave_price_df$ave_price, na.rm=T), max(state_ave_price_df$ave_price, na.rm=T)))
    ggsave(sprintf("../res/w_soldout/map_us_%s.png", std_genre_name), plot=p, width=10, height=6)
}
