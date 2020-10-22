
--1.	For each Customer, list customer name, address , phone number 

select firstName + ' ' + lastName as fullName, street + ' ' + city + ',' + stateInitial + ',' + zipCode as address, phoneNumber from person
inner join customer
on customer.custID = person.personID

--2.	For each category of item, list the category and the amount of sales that has been generated

select itemTypeDescription, sum(qtySold * SALES_ORDER_DETAIL.unitPrice) as subtotal from SALES_ORDER_DETAIL
inner join
ITEM
on item.upc = SALES_ORDER_DETAIL.upc
inner join ITEM_TYPE
on item.itemTypeID = ITEM_TYPE.itemTypeID
group by itemTypeDescription


--3. For each Item, list the upc, description, and how much income was generated.  Income will be the (quantity sold * unit price) minus  (quantity purchased * unit cost)

select amountGotTable.upc, amountGotTable.ItemName, (amountGotTable.amountGot - AmountPaidTable.amountPaid) as Income from
		(select Item.upc, ItemName, sum(qtySold * SALES_ORDER_DETAIL.unitPrice) as amountGot from item
			inner join SALES_ORDER_DETAIL
				on item.upc = SALES_ORDER_DETAIL.upc
				group by item.upc, itemName) as amountGotTable
				inner join
		(select Item.upc, sum(subtotal) as amountPaid from item
			inner join PURCHASE_LINE
				on item.upc= PURCHASE_LINE.upc
				group by ITEM.upc) as amountPaidTable
		on AmountGotTable.upc = amountPaidTable.upc

--4. For each item, list the item, description, vendor name and the number of times its price has been discounted.
select itemName, vendorName, count(discounted_item.upc) as NumTimesDiscounted
from item left outer join discounted_item on Item.upc = discounted_item.upc
inner join vendor on item.vendorID = Vendor.vendorID
 where startDate < getDate() or startDate is null 
group by itemName, vendorName

--5.  For a given date, list which items' prices have been discounted on that date.
select itemName
from item inner join discounted_item on item.upc = discounted_item.upc
where '2020-01-10' >= startdate and '2020-01-10' <= enddate

--6. Which item has been purchased the most often?
select itemName
	from item 
	inner join sales_order_Detail 
		on item.upc = sales_order_detail.upc
		group by itemName
			having count(sales_order_detail.upc) = (
				select max(NumTimesPurchased) from
					(select count(upc) NumTimesPurchased
							from sales_order_detail group by upc) as ItemsPurchased)



--7.	Which cashier has rung up the largest total of sales?
select cashierID, firstName+' '+lastName as cashier from SALES_ORDER
	inner join PERSON
		on SALES_ORDER.cashierId = person.personID
where totalSale
in (select max(totalSale) from SALES_ORDER)


--8.    How many items are supplied by each Vendor?
select vendorName, count(ITEM.vendorID) as [Num supplied] from VENDOR
	inner join ITEM
		on VENDOR.vendorId = ITEM.vendorID
		group by vendorName

--9. List the upc, description, vendor name of each item for which the quantity in stock is less that reorder level
 --(there are no items for which the quantity in stock is less than the reorder level for our data)
select upc, itemName, vendorName
from item inner join vendor on item.vendorid = vendor.vendorID
where qtyInInventory < reorderLevel


--10.  What is the description of the item that is the most expensive item (unit price) in inventory?
select itemName from ITEM
	where unitPrice = (select max(unitPrice) from ITEM)



--11.	List each EBT card on file, the name of the Customer, current balance on the card, 
--and when (date) it was last used to pay for a Sale

--we did not store the customer balance after a lengthy discussion with you

select firstName + ' ' +  lastName as custName, CUSTOMER_EBT_CARD.cardNum, max(dateOfsale) as lastUsed from person
inner join CUSTOMER_EBT_CARD
on person.personID = CUSTOMER_EBT_CARD.custID
inner join SALES_ORDER
on person.personID = SALES_ORDER.custId
inner join payment
on SALES_ORDER.salesOrderID = payment.orderNum
inner join PAYMENT_DETAILS
on payment.paymentId = PAYMENT_DETAILS.paymentID
where paymentType = 4
group by firstName, lastName, CUSTOMER_EBT_CARD.cardNum

--12.  Which customer has generated the most sales?
	--(we took it to mean the customer came to the store the most times)
	
select firstName, lastName from PERSON
	inner join SALES_ORDER
		on PERSON.personID = SALES_ORDER.custId
		group by firstName, lastName
		having count(SALES_ORDER.custId) = (select max(counted) from
				(select count(custID) as counted from SALES_ORDER 
					where custId is not null
						group by custId)as CountedCustomers)


--13.	Which category of item has generated the largest dollar amount of sales?
select itemTypeDescription from item
	inner join SALES_ORDER_DETAIL
		on item.upc = SALES_ORDER_DETAIL.upc
		inner join ITEM_TYPE
			on item.itemTypeID = ITEM_TYPE.itemTypeID
	group by ITEM_TYPE.itemTypeDescription
	having sum(qtySold * SALES_ORDER_DETAIL.unitPrice) in
	(select max(subtotal) from
		(select sum(qtySold * Sales_Order_Detail.unitPrice)as subtotal from SALES_ORDER_DETAIL 
			inner join item
				on item.upc = SALES_ORDER_DETAIL.upc
					group by item.itemTypeID )as subtotals)



--14. For each vendor list the vendor information and the description of each Item that the vendor provides.
select vendor.vendorID, vendorName, phoneNum, street, city, stateInitial, zipCode, itemName
from vendor inner join item on vendor.vendorid = item.vendorid
group by vendor.vendorID, vendorName,  phoneNum, street, city, stateInitial, zipCode, itemName



--15.  List the SalesOrders that were sold without identifying a customer
select * from SALES_ORDER where custId is null


--16.  From which Vendor(s) have no purchase orders been generated during the current month.
select distinct vendorName from VENDOR
	left outer join PURCHASE_ORDER
				on VENDOR.vendorId = PURCHASE_ORDER.vendorID
		group by  vendorName, dateOfOrder
		having  (year(dateOfOrder) = year(getDate()) and month(dateOfOrder) != month(getDate())) or year(dateOfOrder) != year(getDate()) or dateOfOrder is null



--17.  To which Customers have no sales orders been generated during the last 30 days.
select firstName, lastName from PERSON 
	inner join SALES_ORDER 
		on PERSON.personID = SALES_ORDER.custId 
		group by firstName, lastName
		having dateDiff(day,max(dateOfSale), getDate()) > 30

--18. List the names of Customers who have purchased items of both categories of MEAT and FISH.
select distinct concat(firstName, ' ' , lastName) as CustName
from  person inner join 
((select custId from sales_order 
	inner join sales_order_detail on sales_order.salesOrderId = sales_order_detail.salesOrderID
	inner join item on sales_order_detail.upc = item.upc
	inner join ITEM_TYPE on item.itemTypeID = ITEM_TYPE.itemTypeID
		where itemTypeDescription = 'Meat') 
		intersect
(select custId from sales_order 
	inner join sales_order_detail on sales_order.salesOrderId = sales_order_detail.salesOrderID
	inner join item on sales_order_detail.upc = item.upc
	inner join ITEM_TYPE on item.itemTypeID = ITEM_TYPE.itemTypeID
		where itemTypeDescription = 'Fish')) as both
	on person.personID = both.custId



--19.	List the names of each Vendor who supplies all the same categories of items as Vendor 'X'
select vendorName from vendor
inner join
(select distinct vendorID 
from item item1
where not exists
(select itemTypeID from item
where vendorID = 2
and itemTypeID not in 
(select itemTypeID from item item2
where item2.vendorID = item1.vendorID))) as both
on vendor.vendorId = both.vendorID



--20.	For each item purchased, list how many times this item has been returned by any customer
select item.upc, count(item_return.upc) as numReturns from ITEM
left outer join ITEM_RETURN
	on item.upc = ITEM_RETURN.upc
	group by item.upc




--21.  List the total sales of food items, how much was paid for by EBT and how much by other means. 
select totalFood.totalFoodSale, totalEBT.paidByEBT, (totalFood.totalFoodSale - totalEBT.paidByEBT) as paidByOtherMeans  from
(select sum(qtySold*SALES_ORDER_DETAIL.unitPrice) as totalFoodSale from SALES_ORDER_DETAIL
	inner join item
		on SALES_ORDER_DETAIL.upc = ITEM.upc
			inner join ITEM_TYPE
				on ITEM.itemTypeID = ITEM_TYPE.itemTypeID
				where foodItem = 'Y') as totalFood, 
(select isNull(sum(paymentAmount),0) as PaidByEBT from PAYMENT_DETAILS
	inner join PAYMENT_TYPE
	on PAYMENT_DETAILS.paymentType = PAYMENT_TYPE.paymentTypeID
		where paymentTypeDescription = 'EBT Card') as totalEBT



