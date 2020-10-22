go
create procedure usp_returnAnItem 
@salesOrder int,
@upc bigint,
@qty int

as 
begin
begin try
		begin transaction

			Insert into Item_Return (salesOrderID,upc,qtyReturned) values(@salesOrder,@upc,@qty)

			update Item set qtyInInventory = qtyInInventory +@qty

		commit transaction
end try
begin catch
rollback;
throw;
end catch
end



















go
create procedure usp_addItemToPurchaseOrder

@purchaseOrderID int,
@upc bigint, 
@qtyOrdered int,
@unitCost decimal(6,2)

as
begin
begin try

begin transaction

insert into PURCHASE_LINE (purchaseOrderID, upc, qtyOrdered, unitCost) 
values (@purchaseOrderID, @upc, @qtyOrdered, @unitCost)

declare @subtotal decimal (6,2)
select @subtotal = subtotal from PURCHASE_LINE where purchaseOrderID = @purchaseOrderID and upc = @upc

update PURCHASE_ORDER  set totalDue = totalDue + @subtotal
 where purchaseOrderID = @purchaseOrderID

commit transaction

end try

begin catch
rollback;
throw;
end catch

end










go
create procedure usp_deleteItemInPurchaseOrder
 
 @purchaseOrderID int,
 @upc bigint

as
begin
begin try

begin transaction
  
 declare @subtotal decimal (6,2)
 select @subtotal = subtotal from PURCHASE_LINE where purchaseOrderID = @purchaseOrderID and upc = @upc

delete PURCHASE_LINE where purchaseOrderID = @purchaseOrderID and upc = @upc

update PURCHASE_ORDER  set totalDue = totalDue - @subtotal 
where purchaseOrderID = @purchaseOrderID

commit transaction

end try

begin catch
rollback;
throw;
end catch

end












go
create procedure usp_updateItemInPurchaseOrder

@purchaseOrderID int,
@upc bigint, 
@qtyOrdered int


as
begin

begin try
begin transaction
declare @subtotalBefore decimal(6,2)
select @subtotalBefore = subtotal from PURCHASE_LINE where purchaseOrderID = @purchaseOrderID and upc = @upc

update PURCHASE_LINE set qtyOrdered = @qtyOrdered where purchaseOrderID = @purchaseOrderID and upc = @upc

declare @subtotalAfter decimal (6,2)
select @subtotalAfter = subtotal from PURCHASE_LINE where purchaseOrderID = @purchaseOrderID and upc = @upc

update PURCHASE_ORDER  set totalDue = totalDue - @subtotalBefore where purchaseOrderID = @purchaseOrderID

update PURCHASE_ORDER  set totalDue = totalDue + @subtotalAfter where purchaseOrderID = @purchaseOrderID

commit transaction

end try

begin catch
rollback;
throw;
end catch
end 












go
create procedure usp_addASalesOrderItem
@salesOrderID int,
@upc bigint,
@qty int

as 
begin
begin try
		begin transaction
			declare @unitPrice decimal(5,2)
			select @unitPrice =  unitPrice from Item where upc = @upc
			declare @onSale char(1)
			if @upc not in (select upc from DISCOUNTED_ITEM)
			begin;
				select @onSale = 'N'
			end
			else
			begin
				
				declare @startDate date
				declare @endDate date
				select @startDate = (select max(startDate) from DISCOUNTED_ITEM where startDate <= getDate() and upc=@upc)
				select @endDate = endDate from DISCOUNTED_ITEM where startDate = @startDate and upc = @upc

				if getDate() between @startDate and @endDate
				begin
					select @onSale = 'Y'
					declare @limit int
					select @limit = limit from DISCOUNTED_ITEM where upc = @upc and startDate = @startDate
					If @limit < @qty
					begin; 
					--we have decided that in this store we do not allow the customer to buy more than the limit on an onSale item, because we want the items to be available for as many customers as possible . 
					throw 60001, 'You cannot buy more than the limit on a sale item', 1;				
end
end
				else
				begin
					select @onSale = 'N'
				end
			end

			insert into sales_Order_Detail(salesOrderID, upc, qtySold, unitPrice, onSale)
			values(@salesOrderID, @upc, @qty, @unitPrice, @onSale)

			update SALES_ORDER
			set totalSale =  totalSale + (@qty * @unitPrice)
			where salesOrderID = @salesOrderID

			update Item
			set qtyInInventory =  qtyInInventory - @qty
			where upc = @upc

			commit transaction
end try
begin catch
rollback;
throw;
end catch

end





















go
create procedure usp_updateSalesOrderItem
@salesOrderID int,
@upc bigint,
@qty int

as 
begin
begin try
		begin transaction
			declare @unitPrice decimal(5,2)
			declare @qtyBefore int
	
			select @qtyBefore=  qtySold from SALES_ORDER_DETAIL where salesOrderID= @salesOrderID and upc = @upc

			select @unitPrice = unitPrice from Item where upc = @upc
			
			if (select onsale from SALES_ORDER_DETAIL where salesOrderID = @salesOrderID and upc = @upc) = 'Y'
			begin
				declare @startDate date
				declare @limit int
				select @startDate = (select max(startDate) from DISCOUNTED_ITEM where startDate <= getDate() and upc=@upc)
				select @limit = limit from DISCOUNTED_ITEM where upc = @upc and startDate = @startDate

				if @limit < @qty
				begin;
					throw 60001, 'You cannot buy more than the limit on a sale item', 1;				
				end

			end

			update sales_Order_Detail
			set qtySold = @qty
			where salesOrderId = @salesOrderId and upc = @upc
			
			update SALES_ORDER
			set totalSale = totalSale - (@qtyBefore * @unitPrice)
			where salesOrderID = @salesOrderID

			update SALES_ORDER
			set totalSale = totalSale + (@qty * @unitPrice)
			where salesOrderID = @salesOrderID

			update ITEM
			set qtyInInventory = qtyInInventory + @qtyBefore
			where upc = @upc

			update ITEM
			Set qtyInInventory = qtyInInventory - @qty
			where upc = @upc

			commit transaction
end try
begin catch
rollback;
throw;
end catch

end









go
create procedure usp_deleteASalesOrderItem
@salesOrderID int,
@upc bigint

as 
begin
begin try
		begin transaction
			declare @unitPrice decimal(5,2)
			declare @qty int
			select @qty = qtySold from SALES_ORDER_DETAIL where upc =@upc and salesOrderID = @salesOrderID
			select @unitPrice =  unitPrice from Item where upc = @upc
			
			delete sales_Order_Detail
			where salesOrderId = @salesOrderId and upc = @upc

			update SALES_ORDER
			set totalSale = totalSale - (@unitPrice*@qty)
			where salesOrderID = @salesOrderID

			update Item
			set qtyInInventory = qtyInInventory + @qty
			where upc = @upc

			commit transaction
end try
begin catch
rollback;
throw;
end catch

end














go
create procedure usp_addReceiptOfGoodsItem
@purchaseOrderNum int, 
@receiptId int, 
@upc bigint, 
@qty int
as 
begin
	begin try
		begin transaction
			insert into RECEIPT_OF_GOODS_DETAILS (purchaseOrderID,receiptID, upc, qtyReceived) values (@purchaseOrderNum, @receiptId, @upc, @qty)
			update PURCHASE_LINE set qtyReceived = qtyReceived+@qty 
				where purchaseOrderID = @purchaseOrderNum and upc = @upc
			update ITEM set qtyInInventory = qtyInInventory + @qty
				where upc = @upc
		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch
end






go 
create procedure usp_completeASalesOrder
@salesOrderID int
as
begin
	begin try
		begin transaction
			declare @totalNonSale decimal(6,2)
			declare @minimumPurchase decimal(6,2)
			select @minimumPurchase= minPurchaseForDiscount from SALES_ORDER where salesOrderID = @salesOrderID
			
			declare @itemsNotOnSale table (subtotal decimal (6,2))
			select @totalNonSale = sum(qtySold*unitPrice) from SALES_ORDER_DETAIL where salesOrderID = @salesOrderID and onSale = 'N'


			if @totalNonSale >= @minimumPurchase
			begin
				update SALES_ORDER_DETAIL
				set SALES_ORDER_DETAIL.unitPrice = DISCOUNTED_ITEM.discountPrice
					from SALES_ORDER_DETAIL inner join DISCOUNTED_ITEM 
					on SALES_ORDER_DETAIL.upc = DISCOUNTED_ITEM.upc
						inner join ITEM	
							on DISCOUNTED_ITEM.upc = ITEM.upc
					where SALES_ORDER_DETAIL.onSale = 'Y' and qtySold <= isNull(limit,qtyInInventory)and getDate() between startDate and endDate
				
				declare @totalSale decimal (6,2)

				select @totalSale = sum(qtySold*unitPrice) from SALES_ORDER_DETAIL where salesOrderID = @salesOrderID

				update SALES_ORDER set totalSale= @totalSale where salesOrderID = @salesOrderID
			end


			declare @taxAmount decimal(6,2)
			declare @totalTax decimal(6,2)
			declare @totalTaxablePrice decimal (6,2)
			declare @taxId int
			Declare @totalDue decimal (6,2)

			select @totalTaxablePrice =isnull(sum(SALES_ORDER_DETAIL.unitPrice * qtySold),0 ) from SALES_ORDER_DETAIL inner join ITEM 
				on SALES_ORDER_DETAIL.upc = ITEM.upc
					inner join ITEM_TYPE 
						on Item.itemTypeID = ITEM_TYPE.itemTypeID
							where ITEM_TYPE.taxable = 'Y' and salesOrderID = @salesOrderID

			select @taxAmount = taxAmountPerDollar from TAX where dateEffective = (select max(dateEffective) from TAX where dateEffective <= getDate())
			select @taxId = taxID from TAX where dateEffective = (select max(dateEffective) from TAX where dateEffective <= getDate())
			select @totalTax = @taxAmount *@totalTaxablePrice
			Select @totalDue = @totalTax + (select totalSale from Sales_Order where salesOrderID = @salesOrderID)
			insert into RECEIPT_OF_SALES_ORDER (SalesOrderID, totalTaxablePrice, totalTax, taxId, totalDue) values (@salesOrderID, @totalTaxablePrice, @totalTax, @taxId, @totalDue)


		commit transaction
	end try
	begin catch
		rollback;
		throw;
	end catch
end








