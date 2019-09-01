import lxml.html as lh
import requests
import csv
from trans import trans
from unidecode import unidecode
import networkx as nx

class WikipediaTraverser:
    """
    Contains the network and results dictionaries, also run them through here
    """

    def __init__(self):
        self.network = {}
        # article_name = {distance (int), destination (str), child (str)}

        self.results = {}
        # sorted_first_article (key) = {cycle_list (list), end_type (str)}

        # Wikipedia API Request Credentials
        self.BASE_URL = 'https://en.wikipedia.org/w/api.php'
        self.HEADERS = {'User-Agent': 'Wiki First Link Network - jacoblee628@gmail.com'}

        # Keeps track of # of nodes that lead to philosophy
        self.leadstophil = []
        self.graph = nx.DiGraph()

    def save(self, network_path='wiki_network.csv', results_path='wiki_results.csv', phil_path='leadstophil.csv'):
        """
        Saves everything to disk.

        :param network_path: File path for network
        :param results_path: File path for result
        :param phil_path: File path for leadstophil list
        """
        # Save network
        with open(network_path, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['article', 'distance', 'destination', 'child'])
            for key, value in self.network.items():
                writer.writerow([key, value['distance'], value['destination'], value['child']])

        # Save results
        with open(results_path, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['article', 'end_type', 'cycle_list'])
            for key, value in self.results.items():
                writer.writerow([key, value['end_type'], value['cycle_list']])

        # Save phil
        with open(phil_path, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['num_input', 'leads_to_phil', 'total_articles'])
            counter = 1
            for pair in self.leadstophil:
                writer.writerow([counter, pair[0], pair[1]])
                counter += 1
        print("Saved.")

    def load(self, network_path='wiki_network.csv', results_path='wiki_results.csv', phil_path = 'leadstophil.csv'):
        """
        Load network and results from disk
        """
        # Load network
        with open(network_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)
            for row in reader:
                self.network[row[0]] = {'distance': int(row[1]), 'destination': row[2], 'child': row[3]}

        # Load results
        with open(results_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)
            for row in reader:
                cleaned = row[2][1:-1].replace("'", "")
                cycle_list = []
                for entry in cleaned.split(", "):
                    cycle_list.append(entry)
                self.results[row[0]] = {'cycle_list': cycle_list, 'end_type': row[1]}
        print("Loaded.")

        # Load phil
        with open(phil_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            next(reader)
            output = []
            for row in reader:
                output.append((row[1], row[2]))
        self.leadstophil = output

    def run(self, input):
        """
        Run the traversal through here. Saves results to the class dictionaries
        :param input: String (for single article), list of strings (for specific articles),
                        or integer (for random).
        """

        if isinstance(input, str):
            print("Processing article {}".format(input))
            input = input.replace("_", " ")
            self.traverser(input)
            print("Finished")

        if isinstance(input, list):
            num_loops = len(input)
            print("Processing list")
            for i in range(num_loops):
                i = i.replace("_", " ")
                self.traverser(input[i])
            print("Finished processing {} articles".format(len(input)))

        if isinstance(input, int):
            print("Processing {} random articles.".format(input))

            # Wikimedia limits request sizes to 500. Do it 500 at a time.
            req_num, remainder = divmod(input, 500)
            req_num += 1

            last_iter = True if (input == 1) else False
            if input > 500:
                num_requested = 500
            else:
                num_requested = remainder

            # One loop for each request
            tally = 0
            for req in range(req_num):
                if last_iter is True:
                    num_requested = remainder

                params = {'action': 'query', 'list': 'random', 'rnlimit': num_requested,
                          'rnnamespace': 0, 'format': 'json'}
                result = requests.get(self.BASE_URL, params=params, headers=self.HEADERS).json()

                random_page_list = [page['title'] for page in result['query']['random']]
                for i in range(num_requested):
                    print("Processing: {}".format(trans(unidecode(random_page_list[i]))))
                    self.traverser(trans(unidecode(random_page_list[i])))
                    try:
                        ancestors = len(nx.ancestors(self.graph, 'Philosophy'))
                        total = len(self.network) - 1
                        self.leadstophil.append((ancestors, total))
                    except:
                        self.leadstophil.append((0, len(self.network) - 1))

                tally += num_requested
                print("Processed {} articles".format(tally))

                if last_iter is True:
                    break

                if req == (req_num - 2):
                    last_iter = True

            print("Finished processing {} random articles".format(input))

    def traverser(self, article):
        """
        Better practice to call the runner, but can call this to run an individual article.
        """
        visited = []
        # List formatted:
        # 0 -> article
        # 1 -> distance_to_end

        # List of special_page types to check against
        special_pages = ['/wiki/Geographic_coordinate_system',
                         '/wiki/Wikipedia:',
                         '/wiki/File:',
                         '/wiki/Help:',
                         '/wiki/User_talk:',
                         '/wiki/Special:',
                         '/wiki/Category:',
                         '/wiki/Template:',
                         '/wiki/User:',
                         '/wiki/User_talk',
                         '/wiki/Template_talk',
                         '/wiki/Portal:']

        pageprops = ['disambiguation', 'name list', 'list of']

        while True:
            # CASE: Already visited here on previous traversal
            if article in self.network:
                print("Already visited article {}.".format(article))
                distance_counter = self.network[article]['distance']
                final_destination = self.network[article]['destination']
                child = article
                for item in reversed(visited):
                    distance_counter += 1
                    self.network[item[0]] = {'distance': distance_counter,
                                             'destination': final_destination,
                                             'child': child}
                    self.graph.add_edge(item[0], child)
                    child = item[0]
                return

            # CASE: Reached cycle
            if any(sub[0] == article for sub in visited):
                cycle_list = []
                in_cycle = True
                distance_counter = 0
                for item in reversed(visited):
                    if not in_cycle:
                        distance_counter += 1
                    if in_cycle:
                        cycle_list.append(item[0])
                    item[1] = distance_counter
                    if item[0] == article:
                        in_cycle = False

                # Store cycle info
                cycle_id = sorted(cycle_list)[0]
                self.results[cycle_id] = {'cycle_list': cycle_list,
                                          'end_type': 'cycle'}

                # Submit to network
                child = article
                for item in reversed(visited):
                    self.network[item[0]] = {'distance': item[1],
                                             'destination': cycle_id,
                                             'child': child}
                    self.graph.add_edge(item[0], child)
                    child = item[0]
                print("Reached new cycle: {0}, {1}".format(cycle_id, cycle_list))
                return

            # Finding first links
            # Check if disambiguation or name list page
            params = {'action': 'query', 'format': 'json', 'titles': article, 'prop': 'pageprops'}
            result = requests.get(self.BASE_URL, params=params, headers=self.HEADERS)

            first_link = None
            found = False
            if any(prop in (result.text).lower() for prop in pageprops):
                # If so, parse for links.
                params = {'action': 'parse', 'page': article, 'prop': 'text',
                          'format': 'json', 'redirects': 1}
                result = requests.get(self.BASE_URL, params=params,
                                      headers=self.HEADERS).json()
                # Prep text
                raw_html = trans(unidecode(result['parse']['text']['*']))
                html = lh.fromstring(raw_html)

                for element in html.findall("table"):
                    element.drop_tree()

                for element in html.xpath("//div[contains(@class, 'float')]"):
                    element.drop_tree()

                # For each list item (li) in the article:
                for listitem in html.iter('li'):
                    for link in listitem.iter('a'):
                        link.tail = None
                        # Conditionals to weed out bad links.
                        if 'href' not in link.attrib:
                            continue
                        href = link.get('href')
                        if href[:6] != '/wiki/':
                            continue
                        skip = False
                        for url in special_pages:
                            if url in href:
                                skip = True
                                break
                        if skip:
                            continue
                        if link.get('title') is None:
                            continue

                        # Found link
                        first_link = link.get('title')
                        found = True

                        if "\\" in first_link:
                            first_link = first_link.replace("\\", "")
                        first_link = trans(first_link)
                        if found is True:
                            break
                    if found is True:
                        break

            # If disambiguation treatment doesn't work, treat like normal article and parse for links
            if found is False:
                params = {'action': 'parse', 'page': article, 'prop': 'text',
                          'format': 'json', 'redirects': 1}
                result = requests.get(self.BASE_URL, params=params,
                                      headers=self.HEADERS).json()

                if 'error' in result:
                    print("Dead link {} from parent or error retrieving article.".format(article))
                    self.network[article] = {'distance': 0,
                                             'destination': None,
                                             'child': None}
                    distance_counter = 1
                    child = article
                    for item in reversed(visited):
                        self.network[item[0]] = {'distance': distance_counter,
                                                 'destination': article,
                                                 'child': child}
                        distance_counter += 1
                        child = item[0]
                    self.results[article] = {'cycle_list': None,
                                             'end_type': 'dead'}
                    return

                # Prep text
                raw_html = trans(unidecode(result['parse']['text']['*']))
                html = lh.fromstring(raw_html)

                for element in html.findall("table"):
                    element.drop_tree()

                for element in html.xpath("//div[contains(@class, 'float')]"):
                    element.drop_tree()

                # For each paragraph (p) in the article:
                for paragraph in html.iter('p'):
                    converted = str(lh.tostring(paragraph))
                    stripped = lh.fromstring(strip_parentheses(converted))

                    # For each link in the paragraph,
                    for link in stripped.iter('a'):
                        link.tail = None
                        # Conditionals to weed out bad links.
                        if 'href' not in link.attrib:
                            continue
                        href = link.get('href')
                        if href[:6] != '/wiki/':
                            continue
                        skip = False
                        for url in special_pages:
                            if url in href:
                                skip = True
                                break
                        if skip:
                            continue
                        if link.get('title') is None:
                            continue

                        # Found link
                        first_link = link.get('title')
                        found = True

                        if "\\" in first_link:
                            first_link = first_link.replace("\\", "")

                        first_link = trans(first_link)

                        if found is True:
                            break
                    if found is True:
                        break

                if found is False:
                    # For each list item (li) in the article:
                    for listitem in html.iter('li'):
                        for link in listitem.iter('a'):
                            link.tail = None
                            # Conditionals to weed out bad links.
                            if 'href' not in link.attrib:
                                continue
                            href = link.get('href')
                            if href[:6] != '/wiki/':
                                continue
                            skip = False
                            for url in special_pages:
                                if url in href:
                                    skip = True
                                    break
                            if skip:
                                continue
                            if link.get('title') is None:
                                continue

                            # Found link
                            first_link = link.get('title')
                            found = True

                            if "\\" in first_link:
                                first_link = first_link.replace("\\", "")
                            first_link = trans(first_link)
                            if found is True:
                                break
                        if found is True:
                            break

            # CASE: No links found in article
            if found is False or first_link is None:
                print("Could not find links in {}.".format(article))
                self.network[article] = {'distance': 0,
                                         'destination': article,
                                         'child': None}
                distance_counter = 1
                child = article
                for item in reversed(visited):
                    self.network[item[0]] = {'distance': distance_counter,
                                             'destination': article,
                                             'child': child}
                    self.graph.add_edge(item[0], child)
                    distance_counter += 1
                    child = item[0]

                self.results[article] = {'cycle_list': None,
                                         'end_type': 'terminal'}
                return

            # Update visited
            visited.append([article, None])

            # Prepare for next loop
            article = first_link
            # print(article)

    def in_results(self, article):
        """
        Checks to see if article is in any cycles in the results dictionary.

        Args:
            article: The article to check for.
        Returns:
            Boolean
        """
        for key, value in self.results.items():
            if article in value['cycle_list']:
                print(key, value)
                return True
        return False

    def greatest_distance(self):
        """
        Finds the article in the network with the greatest distance from end.

        Returns:
            Article title + distance from end
        """
        greatest_article = ""
        greatest_distance = 0
        for key, value in self.network.items():
            if value['distance'] > greatest_distance:
                greatest_distance = value['distance']
                greatest_article = key

        return {'article': greatest_article, 'distance': greatest_distance}


def strip_parentheses(string):
    """
    Remove content in parentheses from a string, leaving
    parentheses between <tags> in place

    Args:
        string: the string to remove parentheses from
    Returns:
        the processed string after removal of parentheses
    """
    nested_parentheses = nesting_level = 0
    result = ''
    for c in string:
        # When outside of parentheses within <tags>
        if nested_parentheses < 1:
            if c == '<':
                nesting_level += 1
            if c == '>':
                nesting_level -= 1

        # When outside of <tags>
        if nesting_level < 1:
            if c == '(':
                nested_parentheses += 1
            if nested_parentheses < 1:
                result += c
            if c == ')':
                nested_parentheses -= 1

        # When inside of <tags>
        else:
            result += c
    return result
