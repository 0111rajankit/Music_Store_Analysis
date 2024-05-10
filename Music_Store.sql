--Q1. Who is the senior most employee based on job title ?

SELECT employee_id,first_name,last_name,title,levels
FROM employee 
Where levels= (Select Max(Levels) FROM employee)

--Q2. Which TOP 5 Countries have the most Invoices?

SELECT * FROM invoice;

SELECT billing_country,COUNT(total) AS Most_Invoices
FROM invoice
GROUP BY billing_country
ORDER BY Most_Invoices DESC
LIMIT 5;

--Q3.What are top 3 values of total invoices?

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3

--Q4. Which city has the best customers? 
--We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals

SELECT * FROM invoice;
SELECT billing_city, SUM(total) AS Billing_Total
FROM invoice
GROUP BY billing_city
ORDER BY Billing_Total DESC
LIMIT 5

--Q5. Who is the best customer? 
--The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money


SELECT customer.first_name, customer.last_name, SUM(total) AS Total_Money_spent
FROM customer 
INNER JOIN invoice ON
customer.customer_id=invoice.customer_id
GROUP BY first_name,last_name
ORDER BY Total_Money_spent DESC
LIMIT 1

--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email,first_name,last_name,genre.name AS Genre
FROM genre 
INNER JOIN Track ON 
genre.genre_id=Track.genre_id
INNER JOIN invoice_line ON
Track.track_id=invoice_line.track_id
INNER JOIN invoice ON
invoice.invoice_id=invoice_line.invoice_id
INNER JOIN customer ON 
customer.customer_id=invoice.customer_id
WHERE genre.name='Rock'
ORDER BY email ASC

--2nd Approach
SELECT DISTINCT email,first_name,last_name
FROM customer 
INNER JOIN invoice ON customer.customer_id=invoice.customer_id
INNER JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
	Where track_id IN (SELECT track_id
	FROM track 
	INNER JOIN genre ON 
	genre.genre_id=track.genre_id
	WHERE genre.name LIKE 'Rock')
ORDER BY email ASC;

--Q7. Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name,COUNT(track.track_id)
FROM artist
INNER JOIN album ON artist.artist_id=album.artist_id
INNER JOIN track ON album.album_id=track.album_id
INNER JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name='Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY COUNT(artist.artist_id) DESC
LIMIT 10

--Q8. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.


SELECT name,milliseconds AS song_lengths
FROM track
Where milliseconds > (Select Avg(milliseconds) AS Average_song_length FROM track)
ORDER BY milliseconds DESC

SELECT * FROM customer;
select * from invoice;
select * from invoice_line;
SELECT * FROM genre;
select * from album;
SELECT * from track;
SELECT * from artist;

--Q9. Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent.

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id,artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line 
	INNER JOIN track ON invoice_line.track_id=track.track_id
	INNER JOIN album ON track.album_id=album.album_id
	INNER JOIN artist ON album.artist_id=artist.artist_id
	GROUP BY artist.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
	)
SELECT customer.customer_id, customer.first_name,customer.last_name,best_selling_artist.artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
FROM invoice 
INNER JOIN customer ON invoice.customer_id=customer.customer_id
INNER JOIN invoice_line ON invoice_line.invoice_id=invoice.invoice_id
INNER JOIN track ON invoice_line.track_id=track.track_id
INNER JOIN album ON track.album_id=album.album_id
INNER JOIN best_selling_artist ON best_selling_artist.artist_id=album.artist_id
GROUP BY customer.customer_id, customer.first_name,customer.last_name,best_selling_artist.artist_name
ORDER BY amount_spent DESC;

--Q10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres

WITH popular_genre AS (
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country,genre.name,genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS Row_No
	FROM invoice_line 
	INNER JOIN invoice ON invoice_line.invoice_id=invoice.invoice_id
	INNER JOIN customer ON customer.customer_id=invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country,genre.name,genre.genre_id
	ORDER BY customer.country ASC, purchases DESC 
)
SELECT * FROM popular_genre WHERE Row_No <= 1

--Q11.Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC,total_spending DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

--Q12. 