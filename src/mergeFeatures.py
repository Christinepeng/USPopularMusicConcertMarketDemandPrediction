from cStringIO import StringIO
import os
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


def _fix_date(output):
    return re.sub(r"'(\d\d\d\d\d\d\d\d)'", r"!!str \1", output)


flows = [
    'biz_details',
    'biz_photos',
    'mobile_app_biz_details',  
    'mobile_app_biz_photos',
    'mobile_app_search',
    'mobile_biz_details',
    'mobile_search',
    'search',
]


folder_bmw = '/nail/home/hogan/pg/ad_ctr_batches/ad_ctr_batches/java/ad_ctr_batches_java/resources/experiments/bmw_isetta'
folder_owl = '/nail/home/hogan/pg/ad_ctr_batches/ad_ctr_batches/java/ad_ctr_batches_java/resources/experiments/eagle_owl'
folder_target = '/nail/home/hogan/pg/ad_ctr_batches/ad_ctr_batches/java/ad_ctr_batches_java/resources/experiments/bmw_isetta_m2_v1'


for flow in flows:
    print flow

    path_bmw = os.path.join(folder_bmw, flow+'.yaml')
    path_owl = os.path.join(folder_owl, flow+'.yaml')
    path_target = os.path.join(folder_target, flow+'.yaml')

    dict_bmw = yaml.load(open(path_bmw))
    dict_owl = yaml.load(open(path_owl))
    dict_target = dict()


    # transforms

    ## outdated transforms
    to_be_removed_transform_names = ['ctr_with_impression_indicators::ctr']
    for transform_name in to_be_removed_transform_names:
        dict_bmw['transforms'].pop(transform_name, None)

    dict_target['transforms'] = dict_bmw['transforms']
    dict_target['transforms'].update(dict_owl['transforms'])


    # flows
    dict_target['flows'] = [flow]


    # feature_namespaces
    dict_target['feature_namespaces'] = list()

    ## create dict for features
    feature_dict_bmw = {
        feature['name']: feature
        for feature in dict_bmw['feature_namespaces']
    }
    feature_dict_owl = {
        feature['name']: feature
        for feature in dict_owl['feature_namespaces']
    }

    ## fetch first feature; remove from owl
    f_feature = feature_dict_owl['category_v2']
    feature_dict_owl.pop('category_v2')

    ## fetch last feature; remove from owl
    l_feature = feature_dict_owl['time_of_day']
    feature_dict_owl.pop('time_of_day')

    ## outdated features
    outdated_feature_names = [
        'browser_type',
        'device_family',
        'hour_of_day',
        'day_of_week',
        'day_of_month',
        'category',
        'adv_price_range_root_cat',
        'adv_rating_price_range_root_cat',
        'adv_rating_root_cat',
        'adv_review_count_root_cat',
        'adv_root_category',
        'opp_price_range_root_cat',
        'opp_rating_price_range_root_cat',
        'opp_rating_root_cat',
        'opp_review_count_root_cat',
        'opp_root_category',
        'root_category_product',
        'product_rating_root_cat',
        'q2c_max',
        'q2c_weighted_bucket',
        'qlm_log_marginal_bucket',
        'prior_search_qlm_log_marginal_bucket',
        'city_to_city',
        'ctr_with_impression_indicators',
        'freshness',
        'piecewise_linear_advertiser_distance',
        'prior_search_piecewise_linear_advertiser_distance',
        'polynomial_category_similarity',
        'prior_search_polynomial_category_similarity',
        'referer_host',
        'referer_hostpath',
        'yuv_age',
    ]
    might_be_outdated_feature_names = [
        'biz_is_open_now',
        'business_address',
        'business_site_url',
    ]
    to_be_removed_feature_names = outdated_feature_names + might_be_outdated_feature_names

    for feature_name in to_be_removed_feature_names:
        feature_dict_bmw.pop(feature_name, None)
    diff = set(feature_dict_bmw.keys()) - set(feature_dict_owl.keys())
    #print diff
    assert len(filter(lambda x: 'ccr' not in x, diff)) == 0

    ## merge both dicts into feature_dict_target
    feature_dict_target = feature_dict_bmw
    feature_dict_target.update(feature_dict_owl)

    ## create feature list for target
    dict_target['feature_namespaces'] = list()
    dict_target['feature_namespaces'].append(f_feature)
    for key in sorted(feature_dict_target):
        dict_target['feature_namespaces'].append(feature_dict_target[key])
    dict_target['feature_namespaces'].append(l_feature)

    with open(path_target, 'w') as wf:
        wf.write(_fix_date(_fix_dump(yaml.dump(dict_target, default_flow_style=False))))
