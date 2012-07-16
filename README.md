hcir
====

HCIR Challenge Project - https://sites.google.com/site/hcirworkshop/hcir-2012/challenge

Generating Data
------------

    sudo apt-get install postgresql
    rake data:generate
    cp data /tmp
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
   
    SELECT           row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_1_academic_status FROM academic_status ORDER BY id;
    SELECT      15 + row_number() OVER (ORDER BY id) as node_id, id, forename, surname INTO nodes_2_authors FROM authors ORDER BY id;
    SELECT  357891 + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_3_countries FROM countries ORDER BY id;
    SELECT  358070 + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_4_disciplines FROM disciplines ORDER BY id; 
    SELECT  358095 + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_5_journals FROM journals ORDER BY id;
    SELECT  400549 + row_number() OVER (ORDER BY id) as node_id, id, firstname, lastname, research_interests, main_discipline_id, biographical_info INTO nodes_6_profiles FROM profiles ORDER BY id;
    SELECT 1428747 + row_number() OVER (ORDER BY id) as node_id, id, name INTO nodes_7_public_groups FROM public_groups ORDER BY id;
    SELECT 1463945 + row_number() OVER (ORDER BY id) as node_id, id, title, readers, year INTO nodes_8_publications FROM publication_details ORDER BY id;

The Relationships:

    SELECT P.node_id AS start_node, D.node_id AS end_node, 'by_discipline' AS rel_type, nbr_of_readers
    INTO rels_1_reader_disciplines
    FROM reader_disciplines AS RD
    INNER JOIN nodes_8_publications AS P ON RD.publication_id = P.id
    INNER JOIN nodes_4_disciplines AS D ON RD.discipline_id = D.id
    ORDER BY P.node_id, D.node_id;

    SELECT P.node_id AS start_node, C.node_id AS end_node, 'by_country' AS rel_type, nbr_of_readers
    INTO rels_2_reader_countries
    FROM reader_countries AS RC
    INNER JOIN nodes_8_publications AS P ON RD.publication_id = P.id
    INNER JOIN nodes_3_countries AS C ON RC.country_id = D.id
    ORDER BY P.node_id, C.node_id;

    SELECT P.node_id AS start_node, C.node_id AS end_node, 'by_academic_status' AS rel_type, nbr_of_readers
    INTO rels_3_reader_academic_status
    FROM reader_countries AS RC
    INNER JOIN nodes_8_publications AS P ON RD.publication_id = P.id
    INNER JOIN nodes_1_academic_status AS A ON RC.country_id = D.id
    ORDER BY P.node_id, A.node_id;

    SELECT AS start_node, AS end_node, AS type, 
    INTO _rels
    FROM
    INNER JOIN
    ORDER BY ;


The Graph
---------

    publication -[by_discipline]->      discipline 
    publication -[by_country]->         country
    publication -[by_academic_status]-> academic_status
    
