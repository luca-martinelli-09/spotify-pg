# Database 2 - Project 2 (Property Graph)
## Spotify API

```
- datasets/
- slides/
- spotifyDataReduction.ipynb
- spotifyAPIDataRetrieval.ipynb
- spotifyPeopleDataRetrieval.ipynb
- spotifyDataIngestion.ipynb
- spotifyCredentials.py
- spotifyQueries.py
```

### Setup the DBMS
In order to execute queries and adding data, it is necessary to setup **Neo4j** and creating the database. In **Neo4j**:
- Create a new database with name *SpotifyDB* and password *SpotifyDB*. The reccomended version is the lastest
- Start the database

### Creation of the dataset
Since both spotify charts file and reduced spotify charts are too big for GitHub, it is necessary to manual download and create them.

First download the csv dataset of Spotify Charts from [Kaggle](https://www.kaggle.com/pepepython/spotify-huge-database-daily-charts-over-3-years?select=Database+to+calculate+popularity.csv), then place the bigger file in the folder and rename it to  *spotifyCharts*.

Then, in order, execute:
- *spotifyDataReduction*, to create the reduced file (selecting a chart every week and only 100 tracks for chart)
- *spotifyAPIDataRetrieval*, to get the data about albums, artists, genres, etc...
- *spotifyPeopleDataRetrieval*, to get the data about people of the artists and record labels
- *spotifyDataIngestion*, to import the data in the database

The entire process will take about 5/6 hours.

**NOTE**: Spotify API IDs and tokens are needed. The credentials need to be saved in the file *spotifyCredentials* in the following format:

```python
SPOTIFY_CLIENT_ID = "***"
SPOTIFY_SECRET_ID = "***"
SPOTIFY_REFRESH_TOKEN = "***"
```

To get IDs and tokens follow the [Spotify Documentation](https://developer.spotify.com/documentation/general/guides/authorization/).

### Presentation
The presentation is available at this [link](slides/Spotify_Presentation_Alecci_Martinelli_Ziroldo.pdf).

### In case of quarantine error while ingesting data (DatabaseNotFound)
Open Database Browser, with user system execute

```
CALL dbms.quarantineDatabase("neo4j", false);
```