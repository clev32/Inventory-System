use FINALPROJECT

insert into PERSON (firstName,lastName,phoneNumber, street,zipCode,stateInitial,city)
values('Bill', 'Gates', '6646159619', '1835 73rd Ave NE', '98039', 'NE', 'Medina'),
('Elvis', 'Presley', '9177050312','3764 Elvis Presley Blvd','38116','TN','Memphis'),
('Linus','Torvalds','4248006028','1316 SW Corbett Hill Cir','97219','OR','Portland'),
('Katie','Bouman','8798905791','330 South Chester Avenue','91125','CA','Pasadena'),
('Alexander','Hamilton','8457812662','1600 Pennsylvania Ave NW','20500','DC','Washington')

insert into customer (custID) values (1),(2),(5)

insert into CUSTOMER_EBT_CARD values(5,'0123456789012345678','Alexander Hamilton',4,2022,'12345')

insert into CUSTOMER_CREDIT_CARD values (5, '5412753456789010', 'Alexander Hamilton', 12,2020,'345'), 
(1,'2412751234123546', 'Bill Gates',7,2021,'789')

insert into EMPLOYEE_TYPE (typeDescription) values ('Manager'), ( 'Stock Clerk'), ('Cashier')

insert into EMPLOYEE (empID, empDOB, empSSN, empType) values (1,'1955-10-28','539605125',1), (2,'1935-01-08','409522002',2 ), (3,'1969-12-28', '678233908',3), (4,'1989-05-09', '134273563',3)

insert into TAX (dateEffective, taxAmountPerDollar) values ('2018-05-10',0.05), ('2020-01-05',0.08), ('2022-10-10',9.99)

insert into vendor (vendorName, phoneNum, street, city, stateInitial, zipCode)
values ('Choose Us For Good Prices Inc', '7724040096', '24 Rockaway St' ,'Clearwater', 'FL', '33756'),
('Don''t Choose Them, Choose Us Inc', '8285497882', '6719 214th St', 'Oakland Gardens', 'NY', '11364')

insert into ITEM_TYPE (itemTypeDescription, taxable, foodItem)
values ('Aluminum', 'Y', 'N'),
('Bakery', 'N', 'Y'),
('Candy', 'Y', 'Y'),
('Chicken', 'N', 'Y'),
('Fish', 'N', 'Y'),
('Fruit', 'Y', 'Y'),
('Grocery', 'Y', 'N'),
('Magazines', 'N', 'N'),
('Meat', 'N', 'Y'),
('Paper Goods', 'Y', 'N')

insert into ITEM (upc, itemName, itemTypeID, unitPrice, qtyInInventory, reorderLevel, vendorID)
values (123456789012, 'Cupcake', 2, 1.5, 250,25,1),
(123456789029, 'Milk', 7, 2.75, 150, 25, 1),
(123456789036, 'Mishpacha', 8, 4.25, 50, 10, 1),
(123456789043, 'Paper plates', 10, 5.15, 450,100,1),
(123456789050, 'Eggs', 7,2.4, 300,150,2),
(123456789152, 'Cups', 10,2.15, 400, 50,2)

insert into DISCOUNTED_ITEM (upc, startDate, endDate, limit, discountPrice) values (123456789012, '2020-01-10', '2020-02-15',5,1.0), (123456789029, '2019-12-05','2020-02-14',3,2.15 ), 
(123456789036,'2019-12-06', '2020-01-25',1,4.0 ), (123456789036,'2019-11-15','2019-12-20',5,5.0), (123456789050,'2019-10-15','2019-12-29',2,1.5)


insert into SALES_ORDER (cashierID,custId, minPurchaseForDiscount)
values (3,1,15)
insert into SALES_ORDER (cashierID, minPurchaseForDiscount)
values (4, 15)
Insert into Sales_Order(cashierID, minPurchaseForDiscount)
values(3, 15)

insert into PAYMENT_TYPE (paymentTypeDescription) values ('Cash'), ('Credit Card'), ('Check'), ('EBT Card')

insert into PAYMENT (orderNum) values (1), (2)

insert into PAYMENT_DETAILS (paymentID, paymentType, paymentAmount) values (1,1,22.45), (2,1,29.24)
insert into PAYMENT_DETAILS (paymentID, paymentType, paymentAmount,cardNum) values (2,2,10,'54127412789256')

insert into PURCHASE_ORDER (totalDue, vendorID)
values (0,1),
(0,2)


insert into RECEIPT_OF_GOODS (vendorID) values (1)

insert into PAYMENT_TO_VENDOR (purchaseOrderId, amount) values (1,50)



Exec usp_AddASalesOrderItem 2, 123456789036, 1
Exec usp_AddASalesOrderITem 2, 123456789012, 2
Exec usp_updateSalesOrderItem 2, 123456789012, 3
Exec usp_AddASalesOrderItem 2, 123456789029, 1
Exec usp_deleteASalesOrderItem 2, 123456789029
Exec usp_completeASalesOrder 2


Exec usp_AddASalesOrderITem 1, 123456789012, 3
Exec usp_AddASalesOrderITem 1,123456789050, 4
Exec usp_AddASalesOrderItem 1, 123456789029, 3 -- now it should work 
Exec usp_completeASalesOrder 1


Exec usp_AddASalesOrderItem 3, 123456789043, 50
Exec usp_AddASalesOrderItem 3, 123456789029, 2
Exec usp_completeASalesOrder 3


Exec usp_addItemToPurchaseOrder 1, 123456789012, 600, 0.5
Exec usp_updateItemInPurchaseOrder 1, 123456789012, 500
Exec usp_addItemToPurchaseOrder 1, 123456789036, 25, 4
Exec usp_deleteItemInPurchaseOrder 1, 123456789036
Exec usp_addItemToPurchaseOrder 1, 123456789050, 20, 1.5
Exec usp_addItemToPurchaseOrder 2, 123456789029, 65, 1.25
Exec usp_addReceiptOfGoodsItem 1, 1, 123456789012, 50
Exec usp_addReceiptOfGoodsItem 1, 1, 123456789050, 10



Exec usp_returnAnItem 2, 123456789036, 1

