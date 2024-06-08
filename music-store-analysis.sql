Q1. Who is the senior most employee based on job title?



select  * from employee 
order by levels desc
limit 1;


Q2. Which countries have the most invoices?

select billing_country,count(invoice_id)
from invoice
group by billing_country
order by count(invoice_id) desc;


Q3 What are the top 3 values of invoice?

select * from invoice;

select * from invoice_line;


select total from invoice
order by total desc
limit 3;


Q4. which city has the best customers? return a city that has highest sum of invoice totals return both city name and sum of all invoice totals

select sum(total),billing_city 
from invoice
group by billing_city
order by sum(total) desc
limit 1;


Q5.who is the best customer ? write a query to get the customer who spent the most money?

select * from customer;

select customer.first_name,customer.last_name
from customer
where customer.customer_id in (
	select invoice.customer_id 
	from invoice 
	group by customer_id
	order by sum(total) desc
	limit 1
);


2ND APPROACH



/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select *  from genre;
select * from track;

select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
	select track_id from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock'
	
)
order by email;	
;

/* Write a query that returns the artist name and total track count of top 10 rock bands

*/
select artist.name, count(track.track_id ) as total_tracks
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id 
where track.track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
group by artist.name
order by total_tracks desc
limit 10;

/*SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10; */



/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select * from track;


select track.name from track 
where milliseconds > (
	select avg(milliseconds) from track
)
order by milliseconds desc
;

/* we want to find out how much amount spent by each customer on artists
? write a query to return customer name , artist name and total spent */

select customer_id,sum(total) from invoice 
group by customer_id;


select distinct customer.first_name,customer.last_name,artist.name,sum(total)
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by customer.customer_id, customer.first_name,customer.last_name,artist.name;

with best_selling_artist as(
	select artist.artist_id as artist_id,artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)

select customer.customer_id, customer.first_name,customer.last_name,best_selling_artist.artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as amount_spent
from invoice 
join customer on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join best_selling_artist on best_selling_artist.artist_id = album.artist_id
group by 1,2,3,4
order by 5 desc;





/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with customer_with_country as(
	select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	row_number() over(partition by billing_country order by sum(total) desc) as RowNo
	from invoice 
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc)
select * from customer_with_country where RowNo<=1

