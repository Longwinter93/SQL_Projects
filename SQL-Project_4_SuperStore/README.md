# SQL-Project_4_SuperStore
# INTRODUCTION

***A detailed analysis was performed in all years (2011-2014) and their months regarding Ship Mode, Segment, City, Country, Market, Quantity of Orders, Region, Category, Sub-Category, Product Name and Order Priority.***

I am interested in details about the Sales, Profit and Shipping Cost in all available entities to make calculations and conclusions based on these.
So, if I find anything interesting then I do not hesitate to bring that in also.

The whole steps of my analysis were described in my project in T-SQL files [T-SQL files](https://github.com/Longwinter93/SQL_Projects/tree/main/SQL-Project_4_SuperStore/T-SQL%20files)

# USAGE OF SQL
***View Tables, Temporary tables, Common Table Expressions and Table Variable*** were created to store data.

***JOIN clause*** was used to combine rows from two or more tables (CTE) based on a related column between them.

***Variables*** were declared in order to store data. It was used to calculate the percentage quantity of selected categories and entities in all years.

***A Table-valued functions (TVF)*** were used to return the data of a table type. It was used to return the result of selected categories in all years.

***Scalar functions*** were used to simplify codes in order to make complex calculations.

***A Store procedure*** was used to store the code in order to show the result of the calculation.

***A Pivot*** was used to rotate a table-valued expression by turning the unique values from one column in the expression into multiple columns in the output.

Data was cleaned by using ***String Functions***.

Data was explored by using ***Analytic and Windows functions***.

Data was calculated by using ***Window Functions and Date Functions***.

Data was also pivoted to show it in clear ways.

Statistical description was calculated by using ***Aggregate Functions and Analytic Functions (Median)***.

# ANALYSIS AND CALCULATIONS
Statistical description was calculated.

 The calculation was based on Sales, Profit and Shipping Cost.
 
The cumulative distribution and the percentage rank of Customer and other entities were used to show the top 25 and bottom entities of Sales, Profit and Shipping Cost in all entities.

Customers and another entities possess the sales and profit greater than average sales & profit were also indicated. 
 
TOP10 of Profit and Sales in all entities were also indicated.

The Ranking of all entities were also calculated. 

All entities were divided into 3 groups of the level of Sales and Profit. 

The greatest and Lowest Sales & Profit $ Shipping Cost by all entities were also calculated in each year and each month and each quarter.

The Greatest Profit and Greatest Sales in all years were calculated for country, city and customer.

The greatest and lowest Shipping Cost were also calculated for City, Country and Category with Quantity of Orders. 

The ranking of City based on Shipping Cost was also performed.

The quantity of orders was calculated in all years and their months and quarters for City and Countries.

The quantity of Orders, Sales, Profit and Shipping cost were calculated and indicated year by year in numbers and percentage values.

Shipping Cost by Order Priority (Low, High, Medium and Critical) was also calculated for all Markets.

Shipping Cost by Category for all Markets was also calculated in all years and quarters.

Shipping Cost by Category for all Regions was also calculated in all years and quarters.

Profit & Sales for all Countries by Sub Category were also performed.

The Quantity of Orders was calculated by each product in number and percentage values.

Sales and Profit of Product Name were also calculated.

Running Total and Running Difference of Sales and Profit were calculated (year over year, month over month, quarter over quarter, week of year over week of year, year by year, month by month, quarters by quarters, day by day).

The first of 10 Orders (Product Name) for every customer that purchased more than 90 times was indicated.

The first of 3 Orders and Product names for every customer that purchased more than 5 times on May was indicated.

The first of 3 Orders and Product name for every customer that purchased more than 5 times on January was indicated.

All Orders from any customers who made less than $10 000 in purchases for their first three transactions was calculated.

All Orders from any customers who made more than $100 000 in purchases for their first three transactions was calculated.

The first and last Sales for each day of every month of every year was calculated

The first and last Profit for each day of every month of every year was calculated.

The percentage of daily sales to the total sales was calculated.

The Margin for all categories in each year was measured.

The average value of orders in each year and for category was measured.

The cost of Product in each year and for each category was measured.

The percentage cost of product (%) to the Sales was measured.

The ship duration and the average ship duration were calculated.

Apart from it, more detailed analysis based on another fields were performed and are included also in my project.

# MAIN CONCLUSIONS AND RESULTS
## GENERAL OVERVIEW
The distinct quantity of Customer is 795.

Cyra Reiten made the greatest Profit ($88895798), while Eugene Moren made the greatest Sales ($216801629). Michael Oakman made the lowest Sales ($818861), while Gary Hansen made the lowest Profit (-$81317707)

###### Sales by SEGMENT
The Sales of Segment was calculated. The greatest Sales ($1711004122) and Quantity of Orders (26518) belongs to Customer Segment.

Eugene Moren made the biggest Sales ($216801629) in Home Office Segment.

Anna Hayman made the biggest Sales ($210014240) in Consumer Segment.

Ricardo Sperren made the biggest Sales ($209852643) in Corporate Segment.

Joni Sundaresman made the lowest Sales ($1741397) in Home Office Segment.

Michael Oakman made the lowest Sales ($818861) in Consumer Segment.

Sylvia Foulston made the lowest Sales ($1584262) in Corporate Segment.


###### Profit by SEGMENT 
Cyra Reiten made the biggest Profit ($87530275) in Home Office Segment.

Emily Phan made the biggest Profit ($79986483) in Consumer Segment.

Vivek Grady made the biggest Profit ($68582853) in Corporate Segment.

Anthony Garverick made the lowest Profit ($159543) in Home Office Segment.

Eric Hoffmann made the lowest Profit ($2305) in Consumer Segment.

Muhammed MacIntyre made the lowest Profit ($3214) in Corporate Segment.

###### Sales by CATEGORY
The greatest Quantity of Orders belongs to Office Supplies Category (31273).

Alan Dominguez made the greatest Sales ($60938028) in Furniture Category.

Jill Stevenson made the greatest Sales ($41703840) in Office Supplies Category.

Ricardo Sperren made the greatest Sales ($205322708) in Technology Category.

Neil Franzosisch made the lowest Sales ($33453) in Furniture Category.

Liz Wilingham made the lowest Sales ($198224) in Office Supplies Category.

Rob Beeghly made the lowest Sales ($55461) in Technology Category.

###### Profit by CATEGORY
Technology generates the greatest profit $3991841618.

Stefanie Hollomann made the greatest Profit ($7241599) in Furniture Category.

Sanjit Chand made the greatest Profit ($56040112) in Office Supplies Category.

Cyra Reiten made the greatest Profit ($87512166) in Technology Category.

Neil Franzosisch made the lowest Profit ($429) in Furniture Category.

Julia Barnett  made the lowest Profit ($2768) in Office Supplies Category.

Mike Kennedy made the lowest Profit ($120 in Technology Category.

###### Sales by SHIP MODE
The greatest Quantity of Orders belongs to Standard Class Mode (30775).

Brosina Hoffman made the greatest quantity of the Ship Mode (74) by Standard Class.

Steven Ward made the greatest quantity of the Ship Mode (44) by Second Class.

Craig Reiter  made the greatest quantity of the Ship Mode (29) by First Class.

Tamara Chand made the greatest quantity of the Ship Mode (18) by Same Day.

Andy Reiter made the lowest quantity of the Ship Mode (12) by Standard Class.

Susan Pistek made the lowest quantity of the Ship Mode (1) by Second Class.

Yana Sorensen  made the lowest quantity of the Ship Mode (1) by First Class.

Trudy Schmidt made the lowest quantity of the Ship Mode (1) by Same Day.

Ricardo Sperren made the greatest Sales ($208735410) in Ship Mode Standard Class.

Eugene Moren made the greatest Sales ($164977036) in Ship Mode Second Class.

Cyra Reiten made the greatest Sales ($191784418) in Ship Mode First Class.

Gary McGarr made the greatest Sales ($191139949) in Ship Mode Same Day.

Andy Reiter made the lowest Sales ($85173) in Ship Mode Standard Class.

Kimberly Carter made the lowest Sales ($1564) in Ship Mode Second Class.

Tanja Norvell made the lowest Sales ($99) in Ship Mode First Class.

Rob Haberlin made the lowest Sales ($29) in Ship Mode Same Day.


###### Profit  by SHIP MODE
Standard Class generated the greatest Profit $2831192637.

Hunter Lopez made the greatest Profit ($78486028) in Ship Mode Standard Class.

Eugene Moren made the greatest Profit ($70252025) in Ship Mode Second Class.

Cyra Reiten made the greatest Profit ($86352234) in Ship Mode First Class.

Gary McGarr made the greatest Profit ($63957269) in Ship Mode Same Day.

Vivek Sundaresam made the lowest Profit ($635) in Ship Mode Standard Class.

Clay Cheatham made the lowest Profit ($114) in Ship Mode Second Class.

Shirley Schmidt made the lowest Profit ($72) in Ship Mode First Class.

Tony Sayre made the lowest Profit ($10) in Ship Mode Same Day.

###### Sales by Country 
Mexico made the greatest Sales ($7344899253), while Armenia made the lowest Sales ($7197).

###### Profit by Country
United States generated the greatest Profit ($1799876538), while Chad generated the lowest Sales ($90).

###### Quantity of Orders by City
United States has the greatest quantity of orders 9994, while Swaziland has the lowest quantity of orders (2).

New York City has the greatest quantity of orders (915), while a lot of cities (488) have the lowest quantity of orders (1).

###### Shipping Cost by City
The greatest shipping cost belonged to United States ($216632356), while the lowest one belonged to Eritrea ($855)

###### Sales by City
Mexico City made the greatest Sales ($993630258), while Keller made the lowest one ($6).

###### Sales by Customer and City
Gary McGarr from Quito, Ecuador generated the greatest Sales ($191126545), while Patricl O’Bril from Jacksonville, United Stated generated the lowest Sales ($3).

###### Profit by City
New York City (United States) made the greatest Profit ($389435030), while Cidade Ocidental (Brazil) made the lowest Profit ($6).

###### Profit By Customer and City 
Cyra Reiten from Guatemala, Mixco made the greatest profit ($87308002) in 2012, while David Smith from Mexico, Guadalajara made the lowest profit ($1) in 2012.

Shipping Cost and Quantity of Orders by City and Category.

Jakarta (Indonesia) has the greatest shipping Cost ($119924) with 26 Orders in Low Order Priority.

United States (New York City) has the greatest shipping Cost ($998422) with 554 Orders in Medium Order Priority.

United States (New York City) has the greatest shipping Cost ($1075124) with 266 Orders in High Order Priority.

United States (New York City) has the greatest shipping Cost ($467089) with 65 Orders in Critical Order Priority.

United States  (New York City) has the greatest Shipping Cost ($739318) with 552 Quantity of Orders in Office Supplies Category.

United States  (New York City) has the greatest Shipping Cost ($729310) with 192 Quantity of Orders in Furniture Category.

United States  (New York City) has the greatest Shipping Cost ($1112447) with 171 Quantity of Orders in Technology Category.

New York City (United States) possessed the greatest Shipping Cost ($2581075), while Gitarama (Rwanda) possessed the lowest Shipping Cost ($1).

New York City in Office Supplies Category has the greatest quantity of orders (552), while a few cities have only one quantity of orders in all categories. 

Binders (11.99%) possessed the greatest percentage quantity in  Sub-Category, while Tables (1,68%) has the lowest percentage quantity in Sub-Category.

###### Sales by Sub-Category 
Copiers ($23319431708) made the greatest Sales in Sub Category, while Labels ($44770080) made the lowest Sales. 

###### Profit  by Sub-Category 
Copiers ($3361592012) made the greatest Profit in Sub Category, while Art ($24797208) made the lowest Profit. 

###### Shipping Cost by Sub-Category
Phones ($16767146) made the greatest Shipping Cost, while Labels ($735257) made the lowest Shipping Cost.

###### Sales by Sub-Category based on Category
Bookcases (Sub-Category) made the greatest Sales ($1262471095),while Furnishings (Sub-Category) made the lowest Sales ($257624409) in Furniture.

Appliances (Sub-Category) made the greatest Sales ($909944544),while Labels (Sub-Category) made the lowest Sales ($44770080) in Office Supplies.

Copiers (Sub-Category) made the greatest Sales ($2331943708),while Accessories (Sub-Category) made the lowest Sales ($367419718) in Technology.



###### Profit by Sub-Category based on Category
Chairs (Sub-Category) made the greatest Profit ($294734685),while Chairs (Sub-Category) made the lowest Profit ($118779287) in Furniture.

Binders (Sub-Category) made the greatest Profit ($439151004),while Fasteners (Sub-Category) made the lowest Profit ($9123786) in Office Supplies.

Copiers (Sub-Category) made the greatest Profit ($475704796),while Machines (Sub-Category) made the lowest Profit ($266760987) in Technology.

###### The Quantity of Orders by Product Name
Staples possesses the greatest quantity of Orders (227).

###### The Quantity of Discount By Product Name
Hewlett Copy Machine, Color (Technology, Copiers) possesses the greatest quantity of Discount (2602).

###### Sales by Product Name
Brother Copy Machine, Color made the greatest Sales ($592561665), while Sanitaire Vibra Grommer IR Commercial Upright Vacuum, Replacement Belts made the lowest Sales ($13).

###### Profit  by Product Name
Brother Copy Machine, Color made the greatest Profit ($204148826), while Sanitaire Vibra Grommer IR Commercial Upright Vacuum, Replacement Belts made the lowest Profit ($13).

###### The Quantity of Orders by Customer
Muhammed Yedwab ordered the greatest quantity of products (108), while Michael Oakman ordered the lowest quantity of products (29).

24 Customers made more than 90 Orders.


