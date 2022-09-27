:use fabric

// 1. Pour avoir les 25 premières personnes de la liste des régions Bretagne et Corse
USE fabric.region3
MATCH (p:Person)
RETURN p.firstname AS personName , p.address AS personAddress LIMIT 25
UNION
USE fabric.region5
MATCH (p:Person)
RETURN p.firstname AS personName , p.address AS personAddress LIMIT 25

// 2. Pour avoir la liste des personnes en Bretagne testées positives après le 12 octobre 2021
USE fabric.region3
MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (Center {name:"Bretagne"})
WHERE t.date >date("2021-10-12")
RETURN p.firstname AS firstname, p.lastname AS lastname

// 3. Pour avoir la liste des personnes en Corse et Bretagne testées positives après le 12 octobre 2021
USE fabric.region3
MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (Center {name:"Bretagne"})
WHERE t.date >date("2021-10-12")
RETURN p.firstname AS firstname, p.lastname AS lastname
UNION
USE fabric.region5
MATCH (p:Person)-[t:TESTED {status:"Positif"}]->(Center {name:"Corse"})
WHERE t.date > date("2021-10-12")
RETURN p.firstname AS firstname, p.lastname AS lastname

// 4. Les personnes de Bretagne ayant visité le même lieu après le 12 octobre 2021 et ayant été testées positives
USE fabric.region3
MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (Center {name:"Bretagne"}) 
WHERE t.date >date("2021-10-12")
RETURN p.firstname AS firstname, p.lastname AS lastname
UNION ALL
USE fabric.region3
MATCH (p:Person)-[v:VISITED]->(Lieu {city:"Rennes"})
WHERE v.date >date("2021-10-12")
RETURN p.firstname AS firstname, p.lastname AS lastname
	
// 5. Les personnes ayant visité Rennes le 12/10/2021
USE fabric.region3
MATCH (p:Person) -[:VISITED {date:date("2021-10-12")}]-> (l:Lieu{city:"Rennes"})
RETURN p.firstname AS firstname , p.lastname as lastname

// 6. Les personnes étant testées Positif en 2021 au centre Bretagne et retourner leurs prenoms, noms, et dates de test
USE fabric.region3
MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center{name:"Bretagne"})
WHERE t.date > date("2021-01-01") AND t.date < date("2022-01-01")
RETURN p.firstname AS firstname , p.lastname as lastname, t.date as date

// 7. Les personnes étant vacinnées au centre Bretagne et au centre Normandie en 2021
USE fabric.region3
MATCH (p:Person) -[v:VACCINATED]-> (c:Center{name:"Bretagne"})
WHERE v.date > date("2021-01-01") AND v.date < date("2022-01-01")
RETURN c.name as center, count(p) as num
UNION
USE fabric.region9
MATCH (p:Person) -[v:VACCINATED]-> (c:Center{name:"Normandie"})
WHERE v.date > date("2021-01-01") AND v.date < date("2022-01-01")
RETURN c.name as center, count(p) as num

// 8. Nombres de personnes étant nées après l'an 2000, et étant vaccinées en 2021 dans tous les régions
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person) -[v:VACCINATED]-> (c:Center)
	WHERE v.date > date("2021-01-01") AND v.date < date("2022-01-01")
	AND p.birthdate > date("2000-01-01")
	RETURN c.name as region, count(p) as num
}
RETURN region, num

// 9. Nombre de cas contact de tous les regions le 05/05/2021 (cas contact: les personnes ayant visité le même lieu que les personnes étant testées positif)
positif le 05/05/2021)
UNWIND fabric.graphIds() AS graphId
CALL {
	USE fabric.graph(graphId)
	MATCH (p2:Person) -[v2:VISITED]->(l:Lieu)<-[v1:VISITED]-(p:Person)-[:TESTED {date:date("2021-05-05"), status:"Positif"}]-> (c:Center)
	WHERE v2.date = v1.date
	RETURN COUNT(p2) AS num
}
RETURN sum(num) AS cascontact

// 10. Nombre de personnes ayant le passe vaccinal(vaccinées plus de 3 fois)
UNWIND fabric.graphIds() AS graphId
CALL {
	USE fabric.graph(graphId)
	MATCH (p:Person)-[r:VACCINATED]->(c:Center) WITH p, COUNT(r) AS num WHERE num>3
	RETURN count(p) as num
}
RETURN sum(num) AS vaccine

// 11. Total de tests positifs et negatifs dans la france
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2021-01-01") AND t.date < date("2022-03-01")
    RETURN count(p) as nump
}
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person) -[t:TESTED {status:"Negatif"}]-> (c:Center)
    WHERE t.date > date("2021-01-01") AND t.date < date("2022-03-01")
    RETURN count(p) as numn
}
RETURN sum(nump) AS Positif, sum(numn) AS Negatif 


// 12. Total de cas positif par genre 
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person {genre:"Homme"}) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2019-12-31") AND t.date < date("2022-03-01")
    RETURN count(p) as numh
}
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person {genre:"Famme"}) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2019-12-31") AND t.date < date("2022-03-01")
    RETURN count(p) as numf
}
RETURN sum(numh) AS Homme, sum(numf) AS Femme

// 13. Nombre de personnes par région atteintes au moins une fois du covid19
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2020-01-01") AND t.date < date("2022-03-01")
    RETURN c.name as center, count( DISTINCT  p) as num
}
RETURN center, num ORDER BY center 

// 14. Nombre de personnes atteintes au moins une fois du covid19
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2020-01-01") AND t.date < date("2022-03-01")
    RETURN count( DISTINCT  p) as num
}
RETURN sum(num) as Positif

// 15. Les villes avec les cas positifs
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (l:Lieu) <-[v:VISITED]-(p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2020-01-01") AND t.date < date("2022-03-01")
    RETURN  DISTINCT  l.city as city
}
RETURN city as Ville

// 16. Les lieux visités par des personnes pandants quelles avaient le covid19
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (l:Lieu) <-[v:VISITED]-(p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2020-01-01") AND t.date < date("2022-03-01") 
    AND v.date >= t.date   AND  v.date <= t.date + duration("P7D")
    WITH DISTINCT  l.address as address,  count(p) AS totalp

    WHERE totalp > 1
    RETURN address as address
}
RETURN address as lieux

// 17. les clusters (Les lieux avec au moins 4 cas positifs)
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (l:Lieu) <-[v:VISITED]-(p:Person) -[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE t.date > date("2020-01-01") AND t.date < date("2022-03-01") 
    AND v.date >= t.date   AND  v.date <= t.date + duration("P7D")
    WITH DISTINCT  l.address as address,  count(p) AS totalp

    WHERE totalp >=4 
    RETURN address as address, totalp as totalp
}
RETURN address as lieux, totalp as totalvisit

// 18. Cas contact d'une personne en particulier
 UNWIND fabric.graphIds() AS graphId 
 CALL {
     USE fabric.graph(graphId)
     MATCH (p2:Person)-
     [:VISITED]->(l:Lieu) <-[v:VISITED]-(p:Person {firstname:"Paris",lastname:"Célia"})-[t:TESTED {status:"Positif"}]-> (c:Center)
     WHERE (t.date > date("2020-01-01") AND t.date < date("2022-03-01") 
     AND v.date >= t.date   AND  v.date <= t.date + duration("P7D")) OR (p2.address = p.address)

     RETURN DISTINCT p2 AS contact, c
 }
 RETURN contact.firstname AS name , contact.lastname AS lastname , contact.address AS address, c.name AS centre

// 19. Trouver automatiquement les cas contact
UNWIND fabric.graphIds() AS graphId 
CALL {
    USE fabric.graph(graphId)
    MATCH (p2:Person)-
    [:VISITED]->(l:Lieu) <-[v:VISITED]-(p:Person)-[t:TESTED {status:"Positif"}]-> (c:Center)
    WHERE (t.date > date("2020-01-01") AND t.date < date("2022-03-01") 
    AND v.date >= t.date   AND  v.date <= t.date + duration("P7D")) OR (p2.address = p.address)

    RETURN DISTINCT p2 AS contact, c
}
RETURN contact.firstname AS name , contact.lastname AS lastname , contact.address AS address, c.name AS centre
