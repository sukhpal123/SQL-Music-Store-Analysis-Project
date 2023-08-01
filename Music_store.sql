Use Music_Store_database;
-- Q1: Who is the senior most employee based on job title?
SELECT TOP 1 * FROM employee ORDER BY levels DESC 
-- Q2: which countries have the most invoices?
select TOP 1 billing_country, count(*) as Invoice_count from invoice group by billing_country order by Invoice_count desc;
-- Q3: what are the top 3 values of total_invoice
select TOP 3 total from invoice order by total desc;
-- Q4: which city has the best customers? We should like to throw a promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
select Top 1 billing_city, sum(total) as Total_Invoice from invoice group by billing_city order by Total_Invoice desc;
-- Q5 Who is the best customer? the customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.
select Top 1 customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as Total_Invoice from customer join invoice on customer.customer_id = invoice.customer_id 
group by customer.customer_id, customer.first_name, customer.last_name order by Total_Invoice desc;

-- Q6 Write a query to return the email,first name,last name & genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.
select distinct email,first_name,last_name,genre.name from customer join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id where email LIKE 'a%' and genre.name like 'Rock' order by email ;
--OR
select distinct email,first_name,last_name from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
select track_id from track join genre on track.genre_id = genre.genre_id where genre.name like 'Rock' )
order by email ;

--Q7 Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and 
--total track count of the top 10 rock bands
select TOP 10 artist.artist_id ,artist.name,count(track.track_id)as track_count from artist join album on artist.artist_id = album.artist_id
join track on album.album_id=track.album_id
join genre on track.genre_id= genre.genre_id where genre.name like 'Rock' group by artist.artist_id ,artist.name order by track_count desc;

-- Q8 Retun all the track names that have a song length longer than the average song length. return the name and milliseconds for each track. 
--order by the song length with the longest songs listed first
 select name, milliseconds from track where milliseconds > (select AVG(milliseconds) as avg_track_length from track) order by milliseconds desc;

 --Q9 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

 with best_artist AS(
 select TOP 1 artist.artist_id AS artist_id, artist.name AS artist_name,SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales from invoice_line
 join track on track.track_id = invoice_line.track_id
 join album on album.album_id = track.album_id
 join artist on artist.artist_id = album.artist_id 
 group by artist.artist_id, artist.name 
 order by total_sales desc
 )
 select c.customer_id,c.first_name,c.last_name,ba.artist_name,SUM(il.unit_price * il.quantity) AS amount_spent
 FROM invoice i 
 join customer c on c.customer_id = i.customer_id
 join invoice_line il on il.invoice_id = i.invoice_id
 join track t on t.track_id = il.track_id
 join album a on a.album_id = t.album_id
 join best_artist ba on ba.artist_id = a.artist_id
 group by c.customer_id,c.first_name,c.last_name,ba.artist_name
 order by 5 desc;

 --Q10 We want to find out the most popular music genre for each country. we determine the most popular genre as the genre with the highest amount of purchases.
 --write a query that returns each country along with the top genre. for countries where the maximum number of purchases is shared return all genres.
 with popular_genre AS(
 select count(invoice_line.quantity) as total_purchase,customer.country, genre.name,genre.genre_id, 
 ROW_NUMBER() OVER(PARTITION BY customer.country order by count(invoice_line.quantity) DESC) as Rowno
 from invoice_line
 join invoice on invoice.invoice_id = invoice_line.invoice_id
 join customer on customer.customer_id = invoice.customer_id
 join track on track.track_id = invoice_line.track_id
 join genre on genre.genre_id = track.genre_id 
 group by customer.country, genre.name,genre.genre_id
 )
 select * from popular_genre where Rowno <=1


 --Q11 write a query that determines the customer that has spent the most on music for each country. write a query that returns the country along with the
 -- top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.

 WITH customer_with_country AS(
 select customer.customer_id, first_name,last_name,billing_country, SUM(total) as total_spending,
 ROW_NUMBER() OVER(PARTITION BY billing_country order by SUM(total) DESC, billing_country asc) as Rowno
 from invoice 
 join customer on customer.customer_id = invoice.invoice_id
 group by customer.customer_id,first_name,last_name,billing_country
)
 select * from customer_with_country where Rowno <= 1 order by billing_country asc, total_spending desc