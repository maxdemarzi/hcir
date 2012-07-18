hcir
====

HCIR Challenge Project - https://sites.google.com/site/hcirworkshop/hcir-2012/challenge


The Graph
---------

    publication -[by_discipline]->      discipline 
    publication -[by_country]->         country
    publication -[by_academic_status]-> academic_status
    publication -[authored_by]->        author
    publication -[published_in]->       journal
    author      -[has_profile]->        profile
    profile     -[interested_in]->      discipline      
    profile     -[member_of]->          group
    profile     -[knows]->              profile
    
    
Generating Data
------------

    sudo apt-get install postgresql
    psql -U max -d template1
    CREATE DATABASE hcir;
    rake data:generate
    cp data/* /tmp
    copy all your data files (received from dropbox) to /tmp so Postgres can load them without issue

Cleaning Data
-------------

    tr -s '\r' ' ' < profiles > profiles2
    tr -s '"' ' ' < profiles2 > profiles3
    tr -s '"' ' ' < public_groups > public_groups2
    tr -s '"' ' ' < publication_details > publication_details2


Extracting Data
---------------

	CREATE TABLE academic_status (id integer, name varchar(255));
	COPY academic_status FROM '/tmp/academic_status' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE contacts (id1 integer, id2 integer);
	COPY contacts FROM '/tmp/contacts' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE disciplines (id integer, name varchar(255));
	COPY disciplines FROM '/tmp/disciplines' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE profiles (id integer, firstname varchar(255), lastname varchar(255), research_interests text, main_discipline_id integer, biographical_info text);
	COPY profiles FROM '/tmp/profiles3' DELIMITER E'\t' CSV HEADER ESCAPE '\';
	
	CREATE TABLE public_group_members (profile_id integer, group_id integer);
	COPY public_group_members FROM '/tmp/public_group_members' DELIMITER E'\t' CSV HEADER;
	
	CREATE TABLE public_groups (id integer, name varchar(255));
	COPY public_groups FROM '/tmp/public_groups2' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE authors (id integer, forename varchar(255), surname varchar(255));
	COPY authors FROM '/tmp/authors' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE publication_authors (publication_id varchar(50), author_id integer);
	COPY publication_authors FROM '/tmp/publication_authors' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE journals (id integer, name varchar(255));
	COPY journals FROM '/tmp/journals' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE countries (id integer, name varchar(255));
	COPY countries FROM '/tmp/countries' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE reader_countries (publication_id varchar(50), country_id integer, nbr_of_readers int);
	COPY reader_countries FROM '/tmp/reader_countries' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE reader_academic_status (publication_id varchar(50), academic_status_id integer, nbr_of_readers int);
	COPY reader_academic_status FROM '/tmp/reader_academic_status' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE reader_disciplines (publication_id varchar(50), discipline_id integer, nbr_of_readers int);
	COPY reader_disciplines FROM '/tmp/reader_disciplines' DELIMITER E'\t' CSV HEADER;

	CREATE TABLE publication_details (id varchar(50), title varchar(500), primary_author_id integer, readers integer, year integer, publication_id integer);
	COPY publication_details FROM '/tmp/publication_details2' DELIMITER E'\t' CSV HEADER;


Transforming Data
-----------------

The Nodes:
   
    SELECT row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_1_academic_status FROM academic_status ORDER BY id;
    SELECT (SELECT MAX(node_id) FROM nodes_1_academic_status) + row_number() OVER (ORDER BY id) as node_id, id, forename, surname INTO nodes_2_authors FROM authors ORDER BY id;
    SELECT (SELECT MAX(node_id) FROM nodes_2_authors) + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_3_countries FROM countries ORDER BY id;
    SELECT (SELECT MAX(node_id) FROM nodes_3_countries) + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_4_disciplines FROM disciplines ORDER BY id; 
    SELECT (SELECT MAX(node_id) FROM nodes_4_disciplines) + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_5_journals FROM journals ORDER BY id;
    SELECT (SELECT MAX(node_id) FROM nodes_5_journals) + row_number() OVER (ORDER BY id) as node_id, id, firstname, lastname, research_interests, main_discipline_id, biographical_info INTO nodes_6_profiles FROM profiles ORDER BY id;
    SELECT (SELECT MAX(node_id) FROM nodes_6_profiles) + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_7_public_groups FROM public_groups ORDER BY id;
    SELECT (SELECT MAX(node_id) FROM nodes_7_public_groups) + row_number() OVER (ORDER BY id) as node_id, id, title, readers, year INTO nodes_8_publications FROM publication_details ORDER BY id;

The Relationships:

    SELECT P.node_id AS start_node, D.node_id AS end_node, 'by_discipline'::varchar(255) AS rel_type, nbr_of_readers
    INTO rels_1_reader_disciplines
    FROM reader_disciplines AS RD
    INNER JOIN nodes_8_publications AS P ON RD.publication_id = P.id
    INNER JOIN nodes_4_disciplines AS D ON RD.discipline_id = D.id
    GROUP BY P.node_id, D.node_id, nbr_of_readers
    ORDER BY P.node_id, D.node_id;

    SELECT P.node_id AS start_node, C.node_id AS end_node, 'by_country'::varchar(255) AS rel_type, nbr_of_readers
    INTO rels_2_reader_countries
    FROM reader_countries AS RC
    INNER JOIN nodes_8_publications AS P ON RC.publication_id = P.id
    INNER JOIN nodes_3_countries AS C ON RC.country_id = C.id
    GROUP BY P.node_id, C.node_id, nbr_of_readers
    ORDER BY P.node_id, C.node_id;

    SELECT P.node_id AS start_node, A.node_id AS end_node, 'by_academic_status'::varchar(255) AS rel_type, nbr_of_readers
    INTO rels_3_reader_academic_status
    FROM reader_academic_status AS RAS
    INNER JOIN nodes_8_publications AS P ON RAS.publication_id = P.id
    INNER JOIN nodes_1_academic_status AS A ON RAS.academic_status_id = A.id
    GROUP BY P.node_id, A.node_id, nbr_of_readers
    ORDER BY P.node_id, A.node_id;

    SELECT A.node_id AS start_node, P.node_id AS end_node, 'has_profile'::varchar(255) AS rel_type
    INTO rels_4_author_profiles
    FROM nodes_2_authors AS A
    INNER JOIN nodes_6_profiles AS P ON A.forename = P.firstname AND A.surname = P.lastname
    GROUP BY P.node_id, A.node_id
    ORDER BY P.node_id, A.node_id;

    SELECT P.node_id AS start_node, J.node_id AS end_node, 'published_in'::varchar(255) AS rel_type
    INTO rels_5_publication_journals
    FROM publication_details AS PD
    INNER JOIN nodes_8_publications AS P ON P.id = PD.id
    INNER JOIN nodes_5_journals AS J ON PD.publication_id = J.id
    GROUP BY P.node_id, J.node_id
    ORDER BY P.node_id, J.node_id;

    SELECT P.node_id AS start_node, A.node_id AS end_node, 'authored_by'::varchar(255) AS rel_type
    INTO rels_6_publication_authors
    FROM publication_authors AS PA
    INNER JOIN nodes_8_publications AS P ON PA.publication_id = P.id
    INNER JOIN nodes_2_authors AS A ON PA.author_id = A.id
    GROUP BY P.node_id, A.node_id
    ORDER BY P.node_id, A.node_id;

    SELECT P.node_id AS start_node, G.node_id AS end_node, 'member_of'::varchar(255) AS rel_type
    INTO rels_7_profile_groups
    FROM public_group_members AS PM
    INNER JOIN nodes_6_profiles AS P ON PM.profile_id = P.id
    INNER JOIN nodes_7_public_groups AS G ON PM.group_id = G.id
    GROUP BY P.node_id, G.node_id
    ORDER BY P.node_id, G.node_id;

    SELECT P.node_id AS start_node, D.node_id AS end_node, 'interested_in'::varchar(255) AS rel_type
    INTO rels_8_profile_disciplines
    FROM nodes_6_profiles AS P
    INNER JOIN nodes_4_disciplines AS D ON P.main_discipline_id = D.id
    GROUP BY P.node_id, D.node_id
    ORDER BY P.node_id, D.node_id;

    SELECT P1.node_id AS start_node, P2.node_id AS end_node, 'knows'::varchar(255) AS rel_type
    INTO rels_9_contacts
    FROM contacts AS C
    INNER JOIN nodes_6_profiles AS P1 ON C.id1 = P1.id
    INNER JOIN nodes_6_profiles AS P2 ON C.id2 = P2.id
    GROUP BY P1.node_id, P2.node_id
    ORDER BY P1.node_id, P2.node_id;

Loading Data
------------

	psql -c "copy (SELECT node_id, name, 'academic_status' AS type
	FROM nodes_1_academic_status
	UNION ALL
	SELECT node_id, ltrim(coalesce(forename,'') || ' ' || coalesce(surname,'') ) AS name, 'author'
	FROM nodes_2_authors
	UNION ALL
	SELECT node_id, name, 'country'
	FROM nodes_3_countries
	UNION ALL
	SELECT node_id, name, 'discipline'
	FROM nodes_4_disciplines
	UNION ALL
	SELECT node_id, name, 'journal'
	FROM nodes_5_journals
	UNION ALL
	SELECT node_id, ltrim(coalesce(firstname,'') || ' ' || coalesce(lastname,'') ) AS name, 'profile'
	FROM nodes_6_profiles
	UNION ALL
	SELECT node_id, name, 'group'
	FROM nodes_7_public_groups
	UNION ALL
	SELECT node_id, title, 'publication'
	FROM nodes_8_publications
	ORDER BY node_id) TO stdout csv header delimiter E'\t'" -o nodes.csv -d hcir

	psql -c "copy (SELECT start_node, end_node, rel_type, nbr_of_readers::varchar(50)
	FROM rels_1_reader_disciplines
	UNION ALL
	SELECT start_node, end_node, rel_type, nbr_of_readers::varchar(50)
	FROM rels_2_reader_countries
	UNION ALL
	SELECT start_node, end_node, rel_type, nbr_of_readers::varchar(50)
	FROM rels_3_reader_academic_status
	UNION ALL
	SELECT start_node, end_node, rel_type, '\t'
	FROM rels_4_author_profiles
	UNION ALL
	SELECT start_node, end_node, rel_type, '\t'
	FROM rels_5_publication_journals
	UNION ALL
	SELECT start_node, end_node, rel_type, '\t'
	FROM rels_6_publication_authors
	UNION ALL
	SELECT start_node, end_node, rel_type, '\t'
	FROM rels_7_profile_groups
	UNION ALL
	SELECT start_node, end_node, rel_type, '\t'
	FROM rels_8_profile_disciplines
	UNION ALL
	SELECT start_node, end_node, rel_type, '\t'
	FROM rels_9_contacts
	ORDER by start_node, end_node
	) TO stdout csv header delimiter E'\t'" -o rels.csv -d hcir

	java -server -Xmx4G -jar ../batch-import/target/batch-import-jar-with-dependencies.jar neo4j/data/graph.db nodes.csv rels.csv node_index vertices fulltext nodes.csv rel_index edges fulltext rels.csv
