-- Total Sales Per employee

SELECT DISTINCT E.EmployeeId,
                E.FirstName || ' ' ||E.LastName Employee_Name,
                E.Title, --TL.Genre_Name,
 printf("%.2f", Sum(I.Total) OVER (PARTITION BY C.SupportRepId)) Total_Sales
FROM Employee E
LEFT JOIN Customer C ON C.SupportRepId = E.EmployeeId
LEFT JOIN Invoice I ON I.CustomerId = C.CustomerId
WHERE Title = 'Sales Support Agent';

-- Compare Sales Vs Add to playlist
 WITH trackplaylist AS
  (SELECT DISTINCT PLT.TrackId ,
                   count(playlistid) OVER (PARTITION BY PLT.TrackId) 'playlists_count'
   FROM PlaylistTrack PLT
   INNER JOIN Track T ON T.TrackId = PLT.TrackId),
      tracksales AS
  (SELECT DISTINCT IL.TrackId ,
                   count(IL.TrackId) OVER (PARTITION BY IL.TrackId) 'sales_count'
   FROM Track T
   INNER JOIN InvoiceLine IL ON IL.TrackId = T.TrackId)
SELECT T.TrackId,
       T.Name,
       P.playlists_count,
       S.sales_count
FROM Track T
INNER JOIN trackplaylist P ON P.TrackId = T.TrackId
LEFT JOIN tracksales S ON S.TrackId = T.TrackId -- Top 50 Song sales
 WITH TrackList AS
  (SELECT S.Name Singer_Name,
          A.Title Album_Title,
          T.TrackId,
          T.Name Song_Title
   FROM track T
   INNER JOIN Album A ON A.AlbumId = T.AlbumId
   INNER JOIN Artist S ON S.ArtistId = A.ArtistId
   ORDER BY singer_name,
            Album_Title,
            Song_Title),
      TrackSales AS
  (SELECT IL.TrackId,
          sum(UnitPrice) Total_Track_Sale,
          sum(Quantity) Total_Track_Quantity
   FROM InvoiceLine IL
   GROUP BY TrackId)
SELECT *
FROM TrackLIst TL
INNER JOIN TrackSales TS ON TL.TrackId = TS.TrackId
ORDER BY Total_TRack_Sale DESC
LIMIT 50;

-- Genre sales
 WITH TrackList AS
  (SELECT T.TrackId,
          T.Name Song_Title,
          G.Name Genre_Name
   FROM Genre G
   LEFT JOIN track T ON T.GenreId = G.GenreId
   ORDER BY T.GenreId),
      total_sales AS
  (SELECT cast(sum(Quantity) AS float) Quantity
   FROM InvoiceLine)
SELECT DISTINCT Genre_Name ,
                Sum(Total_Sales_Quamtity) OVER (PARTITION BY Genre_Name) total_genre_sales ,
                                               (Sum(Total_Sales_Quamtity) OVER (PARTITION BY Genre_Name)/total_sales.Quantity) Sale_percent
FROM
  (SELECT DISTINCT TL.TrackId,
                   TL.Song_Title,
                   TL.Genre_Name ,
                   count(IL.UnitPrice) OVER (PARTITION BY TL.TrackId) Total_Sales_Quamtity
   FROM TrackLIst TL
   LEFT JOIN InvoiceLine IL ON TL.TrackId = IL.TrackId
   LEFT JOIN Invoice I ON IL.InvoiceId = I.InvoiceId
   LEFT JOIN Customer C ON I.CustomerId = C.CustomerId) AS X
CROSS JOIN total_sales
ORDER BY total_genre_sales DESC -- Gener track shares
 WITH trackcount AS
  (SELECT cast(count(trackid) AS float) c
   FROM Track)
SELECT DISTINCT G.Name Genre_Name,
                count(T.TrackId) OVER (PARTITION BY T.GenreId) c, (count(T.TrackId) OVER (PARTITION BY T.GenreId)/trackcount.c) SHARE
FROM Genre G
LEFT JOIN track T ON T.GenreId = G.GenreId
CROSS JOIN trackcount