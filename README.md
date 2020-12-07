This is implementation of Basic Search from scratch. This is a CLI app. 

How to run?
use ruby 2.6.5

```ruby
#navigate to app director 
cd basic_search 
ruby main.rb
```

The data files have to be placed in the `data` directory. The data file is in ``json`` format.

Sample data file which has 2 records (taken from organizations.json). 

```[
     {
       "_id": 101,
       "url": "http://initech.zendesk.com/api/v2/organizations/101.json",
       "external_id": "9270ed79-35eb-4a38-a46f-35725197ea8d",
       "name": "Enthaze",
       "domain_names": [
         "kage.com",
         "ecratic.com",
         "endipin.com",
         "zentix.com"
       ],
       "created_at": "2016-05-21T11:10:28 -10:00",
       "details": "MegaCorp",
       "shared_tickets": false,
       "tags": [
         "Fulton",
         "West",
         "Rodriguez",
         "Farley"
       ]
     },
     {
       "_id": 102,
       "url": "http://initech.zendesk.com/api/v2/organizations/102.json",
       "external_id": "7cd6b8d4-2999-4ff2-8cfd-44d05b449226",
       "name": "Nutralab",
       "domain_names": [
         "trollery.com",
         "datagen.com",
         "bluegrain.com",
         "dadabase.com"
       ],
       "created_at": "2016-04-07T08:21:44 -10:00",
       "details": "Non profit",
       "shared_tickets": false,
       "tags": [
         "Cherry",
         "Collier",
         "Fuentes",
         "Trevino"
       ]
     }
     ]
 ```

Each data file has to accompanied by a config file. The config file should contain schema. Example config file for the above data file

```
{
 "schema": {
   "tokenize_list": [
     "name",
     "domain_names",
     "details",
     "tags"
   ]
 }
}
```

The term `tokenize_list` signifies which of the attributes in the data file, will be tokenized (split into words and each word indexed seperately). All attributes which are not specified part of `tokenize_list` are not tokenized or processed (except for downcasing), and are seachable only by exact match (example: id, external_id, url)


##How is data indexed?


The indexing of a data file produces the following 2 indices.

- SrcIndex
- An array of Attribute Indices, one for each attribute

The SrcIndex is as follows
       
```
        "101" => {
                  "_id": 101,
                  "url": "http://initech.zendesk.com/api/v2/organizations/101.json",
                  "external_id": "9270ed79-35eb-4a38-a46f-35725197ea8d",
                  "name": "Enthaze",
                  "domain_names": [
                    "kage.com",
                    "ecratic.com",
                    "endipin.com",
                    "zentix.com"
                  ],
                  "created_at": "2016-05-21T11:10:28 -10:00",
                  "details": "MegaCorp",
                  "shared_tickets": false,
                  "tags": [
                    "Fulton",
                    "West",
                    "Rodriguez",
                    "Farley"
                  ]
                },
        "102=> {
                  "_id": 102,
                  "url": "http://initech.zendesk.com/api/v2/organizations/102.json",
                  "external_id": "7cd6b8d4-2999-4ff2-8cfd-44d05b449226",
                  "name": "Nutralab",
                  "domain_names": [
                    "trollery.com",
                    "datagen.com",
                    "bluegrain.com",
                    "dadabase.com"
                  ],
                  "created_at": "2016-04-07T08:21:44 -10:00",
                  "details": "Non profit",
                  "shared_tickets": false,
                  "tags": [
                    "Cherry",
                    "Collier",
                    "Fuentes",
                    "Trevino"
                  ]
            }
```

The Attribute indices for few attributes look like this 
###external_id 

```ruby
{
    "9270ed79-35eb-4a38-a46f-35725197ea8d": [1],
    "7cd6b8d4-2999-4ff2-8cfd-44d05b449226": [2]
}
```

###name

```ruby
{
  "enthaze":  [1], 
  "nutralab": [2]
}

```

###tags
```ruby
{
    "cherry": [2],
    "collier": [2],
    "fuentes": [2],
    "trevino": [2],
    "fulton": [1],
    "west": [1],
    "rodriguez": [1],
    "farley": [1]

}

```

With the help of the above indices, we can search for any terms present in the document and return the results. If the search term is not present, then we return an empty response. 