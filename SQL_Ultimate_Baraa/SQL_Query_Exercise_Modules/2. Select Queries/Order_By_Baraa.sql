	-- Sort all customers score from highest to lowest
	SELECT 
	*
	FROM customers
	ORDER BY score DESC

	-- Sort all customers score from LOWEST to HIGHEST
	SELECT 
	*
	FROM customers
	ORDER BY score 

	--Sort customers by country and score HIGHEST TO LOWEST
	select 
	*
	from customers
	order by country ASC, score DESC
