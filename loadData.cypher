// Create constraints

CREATE CONSTRAINT IF NOT EXISTS FOR (g:Genre) REQUIRE g.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (c:Country) REQUIRE c.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (a:Artist) REQUIRE a.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (alb:Album) REQUIRE alb.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (t:Track) REQUIRE t.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (ch:Chart) REQUIRE ch.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Person) REQUIRE p.id IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (i:Instrument) REQUIRE i.instrument IS UNIQUE ;
CREATE CONSTRAINT IF NOT EXISTS FOR (r:RecorLabel) REQUIRE r.id IS UNIQUE ;

// Load genres

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/genres.csv" AS genre
    CREATE (:Genre { id: genre.id, name: genre.name })
;

// Load countries

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/countries.csv" AS country
    CREATE (:Country { id: country.Code, name: country.Name })
;

// Load artists

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/artists.csv" AS artist
    CREATE (a:Artist { id: artist.id, name: artist.name, popularity: artist.popularity })
    
    WITH a, split(artist.genres, ",") AS genres
    UNWIND genres AS genre
        MATCH (g:Genre { id: genre })
        CREATE (a)-[:hasGenre]->(g)
;

// Load albums

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/albums.csv" AS album
    CREATE (alb:Album {
        id: album.id,
        name: album.title,
        totalTracks: toInteger(album.total_tracks),
        releaseDate: date(album.release_date),
        albumType: album.album_type
    })

    WITH album, alb, split(album.artists, ",") AS artists
    UNWIND artists AS artist
        MATCH (a:Artist { id: artist })
        CREATE (a)-[:partecipateIn]->(alb)

    WITH alb, split(album.available_countries, ",") AS countries
    UNWIND countries AS country
        MATCH (c:Country { id: country })
        CREATE (alb)-[:isAvailableIn]->(c)
;

// Load tracks

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/tracks.csv" AS track
    CREATE (t:Track {
        id: track.id,
        name: track.title,
        duration: toInteger(track.duration), 
        popularity: toInteger(track.popularity), 
        explicit: toBoolean(track.explicit),
        key: toInteger(track.key),
        tempo: toFloat(track.tempo),
        mode: toInteger(track.mode),
        time_signature: toInteger(track.time_signature),
        acousticness: toFloat(track.acousticness),
        danceability: toFloat(track.danceability),
        energy: toFloat(track.energy),
        loudness: toFloat(track.loudness),
        liveness: toFloat(track.liveness),
        valence: toFloat(track.valence),
        speechiness: toFloat(track.speechiness),
        instrumentalness: toFloat(track.instrumentalness)
    })

    WITH track, t
    MATCH (alb:Album { id: track.album })
    CREATE (t)-[:isPartOf]->(alb)

    WITH track, t, split(track.artists, ",") AS artists
    UNWIND artists AS artist
        MATCH (a:Artist { id: artist })
        CREATE (a)-[:partecipateIn]->(t)

    WITH t, split(track.available_countries, ",") AS countries
    UNWIND countries AS country
        MATCH (c:Country { id: country })
        CREATE (t)-[:isAvailableIn]->(c)
;

// Load charts

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/charts.csv" AS chart
    MERGE (ch:Chart { id: chart.id, name: chart.name, date: date(chart.date), chartType: chart.type })

    WITH chart, ch
    MATCH (c:Country { id: chart.country_code })
    MERGE (t)-[:isReferredTo]->(c)

    WITH chart, ch
    MATCH (t:Track { id: chart.trackID })
    CREATE (t)-[r:isPositionedIn { position: toInteger(chart.position) }]->(ch)
;

// Load record labels

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/recordLabels.csv" AS recordLabel
    MERGE (r:RecorLabel {
        id: recordLabel.id,
        name: recordLabel.name,
    })

    WITH recordLabel, r
    MATCH (c:Country { id: recordLabel.country })
    MERGE (r)-[:isLocatedIn]->(c)
;

// Load people

LOAD CSV WITH HEADERS FROM "file:///C:/datasets/people.csv" AS person
    MERGE (p:Person {
        id: person.id,
        name: person.name,
        surname: person.surname,
        gender: person.gender,
        birthDate: date(person.birthdate),
        deathDate: date(person.deathdate),
    })

    WITH person, p
    MATCH (c:Country { id: person.nationality })
    MERGE (p)-[:hasNationality]->(c)

    WITH person, p
    MATCH (a:Artist { id: person.artist })
    CREATE (p)-[r:isMemberOf]->(a)

    WITH person, p, split(person.instruments, ",") as instruments
    UNWIND instruments AS instrument
        MERGE (p)-[:plays]->(i:Instrument { name: instrument })

    WITH person, p, split(person.recordLabels, ",") as recordLabels
    UNWIND recordLabels AS recordLabel
        MATCH (r:RecorLabel { id: recordLabel })
        MERGE (p)-[:hasContractWith]->(r)
;