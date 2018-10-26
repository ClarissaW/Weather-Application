# watson personality insight of ibm
from watson_developer_cloud import PersonalityInsightsV3
from watson_developer_cloud import WatsonApiException

from yaspin import yaspin
from yaspin.spinners import Spinners

import json
import os

personality_insights = PersonalityInsightsV3(
      version='2018-07-25',
      username='241d7cbc-843d-434d-95c6-ce968d8f5048',
      password='gqrNiCe4E35C',
      url='https://gateway.watsonplatform.net/personality-insights/api'
      )


def get_clients_metrics_results(profile):
    clients_personality_results = []
    results = json.dumps(profile, indent=2)
    results = json.loads(results)['personality']
    
    for num in range(0,len(results)):
        traits = results[num]['children']
        for trait in range(0, len(traits)):
            if "anger" in traits[trait]['trait_id'] or "depression" in traits[trait]['trait_id'] or "vulnerability" in traits[trait]['trait_id'] or "cheerfulness" in traits[trait]['trait_id'] or "friendliness" in traits[trait]['trait_id'] or "trust" in traits[trait]['trait_id'] or "cooperation" in traits[trait]['trait_id']:
                clients_personality_results.append(traits[trait])
    return {"personality":clients_personality_results}


def get_profile_from_watson(input,client):
    profile = None
    try:
        profile = personality_insights.profile(input,
                                               content_type='application/json',
                                               raw_scores=True, consumption_preferences=True)
    except WatsonApiException as ex:
       print "Method failed with status code " + str(ex.code) + ": " + ex.message
    if (client == True):
        return get_clients_metrics_results(profile)
    else:
        
        return profile

def get_result(path):
    with open(path,'rb') as file:
        data = json.load(file)
        for s in data:
            if s == "advisor" and "Sent" in path:
                input = {"contentItems":data[s]}
                client = False
            elif s == "response" and "Inbox" in path:
                input = {"contentItems":data[s]}
                client = True
            else:
                continue
            result = get_profile_from_watson(input,client)

    return result


#client = False
root = 'output/'
root_path = os.listdir(root)
if not os.path.exists('results'):
    os.mkdir('results')
for path in root_path:
    input_path = root + path
    if "Sent Items" in path:
        if not os.path.exists('results/personality_advisor'):
            os.mkdir('results/personality_advisor')
        output_filename = 'results/personality_advisor/personality_advisor_'+ path.split('@')[0] + '.json'
    elif "Inbox" in path:
        if not os.path.exists('results/personality_clients'):
            os.mkdir('results/personality_clients')
        output_filename = 'results/personality_clients/personality_clients_'+ path.split('@')[0] + '.json'
    else:
        continue
    output_path = root + output_filename
    profile = get_result(input_path)
    if profile is not None:
        results = json.dumps(profile, indent=2)
        with open(output_filename,'w') as file:
            with yaspin(text = 'I am writing the file! Hold on!') as spinner:
                file.write(results)
                spinner.ok()

print('All Done')


#    results = json.dumps(profile, indent=2)
#    results = json.loads(results)
#    personalities = json.dumps(results["personality"],indent = 2)



# Metrics for this: which one is better?

#percentile : The normalized percentile score for the characteristic. The range is 0 to 1. For example, if the percentage for Openness is 0.60, the author scored in the 60th percentile; the author is more open than 59 percent of the population and less open than 39 percent of the population.

#raw_score : The raw score for the characteristic. The range is 0 to 1. A higher score generally indicates a greater likelihood that the author has that characteristic, but raw scores must be considered in aggregate: The range of values in practice might be much smaller than 0 to 1, so an individual score must be considered in the context of the overall scores and their range.

#   The raw score is computed based on the input and the service model; it is not normalized or compared with a sample population. The raw score enables comparison of the results against a different sampling population and with a custom normalization approach.
