
use master 
go
create database FINALPROJECT
go
use FINALPROJECT
go 

create table VENDOR(
	vendorId int identity(1,1),
	vendorName varchar(45) not null,
	phoneNum varchar(10) not null,
	street varchar(20) not null,
	city varchar(25) not null,
	stateInitial varchar(2) not null,
	zipCode varchar(5) not null,
	constraint [PK_VENDOR_vendorId] primary key (vendorId),
	constraint [UIX_vendorPhoneNumber] unique (phoneNum)
)

create table PERSON
(

personID int identity (1,1),
firstName varchar(45) not null,
lastName varchar(45) not null,
phoneNumber varchar(10) not null,
street varchar(45) not null,
zipCode varchar(5) not null,
stateInitial varchar(2) not null,
city varchar (25) not null,

constraint [PK_personID] primary key (personID),
constraint [UIX_PhoneNumber] unique (phoneNumber),
)

create table CUSTOMER
(
custID int not null,

constraint [PK_custID]  primary key(custID), 
constraint [FK_ CUSTOMER_PERSON]  foreign key (custid) references person (personID)

)

create table EMPLOYEE_TYPE
(
typeID int identity(1,1),
typeDescription varchar(45) not null

constraint [PK_typeID] primary key(typeID)
)
create table EMPLOYEE
(
empID int not null,
empDOB date not null,
empSSN varchar(9) not null,
empHireDate as getDate(),
empType int not null,

constraint [PK_empID] primary key (empID),
constraint [FK_EMPLOYEE_PERSON] foreign key (empID) references person (personID),
constraint [FK_EMPLOYEE_EMPLOYEETYPE] foreign key (empType) references EMPLOYEE_TYPE (typeID),
constraint [CHK_empDOB] check (empDOB < getDate()),
Constraint [UIX_empSSN] unique (empSSN)
)


create table CUSTOMER_EBT_CARD(

custID int not null,
cardNum varchar (19) not null,
nameOnCard varchar(25) not null,
expMonth int not null,
expYear int not null,
pinNum varchar(5) not null,


constraint [PK_EBTcardNum] primary key (cardNum),
constraint [FK_CUSTEBTCARD_CUSTOMER] foreign key (custID) references customer(custID),
constraint [CHK_EBTexpMonth] check (expMonth between 1 and 12),
constraint [CHK_EBTexpYear] check (expYear between year(getDate()) and year(dateAdd(year, 5, getDate()))),
constraint [UIX_EBTCustID] unique (custID)

)

create table CUSTOMER_CREDIT_CARD
(
--we realized retrospectively that we should have not made the card number a primary key since --we don't control it

custID int not null,
cardNum varchar (19) not null,
nameOnCard varchar(25) not null,
expMonth int not null,
expYear int not null,
cvvCode char(4) not null,

constraint [PK_creditCardNum] primary key (cardNum),
constraint [FK_CUSTCREDITCARD_CUSTOMER] foreign key (custID) references customer(custID),
constraint [CHK_CreditCardexpMonth] check (expMonth between 1 and 12),
constraint [CHK_CreditCardexpYear] check (expYear between year(getDate()) and year(dateAdd(year, 5, getDate()))),
constraint [UIX_CreditCardCustID] unique (custID)


)



create table TAX(
	taxID int identity(1,1),
	dateEffective date not null,
	taxAmountPerDollar decimal(4,2)  not null,

	constraint [PK_TAX] primary key (taxId)
)

create table ITEM_TYPE(
	itemTypeID int identity(1,1),
	itemTypeDescription varchar(45) not null,
	taxable char(1) not null,
	foodItem char(1) not null,

	constraint [PK_ItemType] primary key (itemTypeID),
	constraint [CHK_taxable_foodItem] check (upper(taxable) in ('Y','N')),
	constraint [CHK_foodItem] check (upper(foodItem) in ('Y', 'N')),
	Constraint [UIX_itemTypeDescription] unique (itemTypeDescription)
)

create table ITEM(
	upc bigInt not null,
	itemName varchar(25) not null,
	itemTypeID int not null,
	unitPrice decimal(5,2) not null,
	qtyInInventory int not null,
	reorderLevel int not null,
	vendorID int not null,

	constraint [PK_Item] primary key (upc),
	constraint [FK_Item_ItemType] foreign key (itemTypeID) references ITEM_TYPE(itemTypeID),
	constraint [FK_Item_Vendor] foreign key (vendorID) references Vendor(vendorID),
	constraint [CHK_itemUnitPrice] check (unitPrice >=0),
	constraint [CHK_qtyInInventory] check (qtyInInventory>=0)
)

create table DISCOUNTED_ITEM(
	upc bigInt not null,
	startDate date not null,
	endDate date not null,
	limit int null,
	discountPrice decimal(5,2) not null,

	constraint [PK_DiscountedItem] primary key (upc, startDate),
	constraint [FK_DiscountedItem] foreign key (upc) references Item(upc)
)


create table SALES_ORDER(
	salesOrderID int identity(1,1),
	dateOfSale as getDate(),
	cashierId int not null,
	totalSale decimal(6,2) 
	constraint [DFLT_totalSale] default (0),
	custId int null,
	minPurchaseForDiscount decimal(4,2) not null,

	constraint [PK_SalesOrder] primary key (salesOrderId),
	constraint [FK_SalesOrder_Employee] foreign key (cashierId) references Employee(empId),
	constraint [FK_SalesOrder_Customer] foreign key (custId) references Customer(custId),
)

create table SALES_ORDER_DETAIL(
	salesOrderID int not null,
	upc bigInt not null,
	qtySold int not null,
	unitPrice decimal(5,2) not null,
	onSale char(1) not null,

	constraint [PK_salesOrderID] primary key (salesOrderID, upc),
	constraint [FK_SalesOrderDetail_SalesOrder] foreign key (salesOrderID) references SALES_ORDER(salesOrderID),
	constraint [FK_SalesOrderDetail_Item] foreign key (upc) references Item(upc),
	constraint [CHK_unitPrice] check (unitPrice >= 0),
	constraint [CHK_onSale] check (upper(onSale) in ('Y', 'N'))
)

create table RECEIPT_OF_SALES_ORDER(
	receiptID int identity(1,1),
	salesOrderID int not null,
	totalTaxablePrice decimal(6,2) not null,
	totalTax decimal(6,2) not null,
	taxId int not null,
totalDue decimal(6,2) not null

	constraint [PK_ReceiptOfSalesOrder] primary key (receiptID),
	constraint [FK_ReceiptOfSalesOrder_SalesOrder] foreign key (salesOrderID) references SALES_ORDER(salesOrderID),
	constraint [FK_ReceiptOfSalesOrder_Tax] foreign key (taxID) references TAX(taxID)
)

create table PAYMENT(
	paymentId int identity(1,1),
	orderNum int not null,

	constraint [PK_paymentId] primary key (paymentId),
	constraint [FK_payment_salesOrder] foreign key (orderNum) references SALES_ORDER(salesOrderId),

)

create table PAYMENT_TYPE(
	paymentTypeID int identity(1,1),
	paymentTypeDescription varchar(25) not null,

	constraint [PK_PAYMENTTYPE] primary key (paymentTypeID),
	constraint [UIX_paymentTypeDescription] unique (paymentTypeDescription)
)

create table PAYMENT_DETAILS(
	paymentID int not null,
	paymentType int not null,
	paymentAmount decimal(6,2) not null,
	cardNum varchar(19) null,

	constraint [PK_PaymentDetails] primary key (paymentID, paymentType),
	constraint [FK_PaymentDetails_PaymentType] foreign key (paymentType) references PAYMENT_TYPE(paymentTypeId),
	constraint [FK_PaymentDetails_Payment] foreign key (paymentID) references PAYMENT(paymentID)
)



create table PURCHASE_ORDER(
	purchaseOrderID int identity(1,1),
	dateOfOrder as getDate(),
	totalDue decimal(6,2)
	constraint [DFLT_totalDue] default(0),
	vendorID int not null,
	constraint [PK_PURCHASEORDER_purchaseOrderID] primary key (purchaseOrderID),
	constraint [FK_PURCHASEORDER_VENDOR] foreign key (vendorID) references VENDOR (vendorID)
)

create table PURCHASE_LINE(
	purchaseOrderID int not null,
	upc bigInt not null,
	qtyOrdered int not null,
	unitCost decimal(6,2) not null,
	subtotal as qtyOrdered * unitCost,
	qtyReceived int null 
	constraint [DFLT_qtyReceived] default(0),
	constraint [PK_PURCHASE_LINE_purchaseOrderID_upc] primary key (purchaseOrderID, upc),
	constraint [FK_PURCHASE_LINE_ITEM] foreign key (upc) references ITEM(upc),
	constraint [CHK_unitCost] check (unitCost >= 0),
	constraint [CHK_qtyOrdered] check (qtyOrdered >0)

)

create table RECEIPT_OF_GOODS(
	receiptID int identity(1,1),
	vendorID int not null,
	constraint [PK_RECEIPT_OF_GOODS_receiptID] primary key (receiptID),
	constraint [FK_RECEIPT_OF_GOOD_VENDOR] foreign key (vendorID) references VENDOR(vendorID)

)

create table RECEIPT_OF_GOODS_DETAILS(
	purchaseOrderID int not null,
	Upc bigInt not null,
	receiptID int not null,
	qtyReceived int not null,
	constraint [PK_RECEIPT_OF_GOODS_DETAILS] primary key (purchaseOrderID, upc, receiptID),
	constraint [CHK_qtyReceived] check (qtyReceived >0),
	constraint [FK_RECEIPT_OF_GOODS_DETAILS_PURCHASE_LINE] foreign key (purchaseOrderID, upc) references PURCHASE_LINE(purchaseOrderID,upc),
	constraint [FK_RECEIPT_OF_GOODS_DETAILS_RECEIPT_OF_GOODS] foreign key (receiptID) references RECEIPT_OF_GOODS(receiptID),

)

create table PAYMENT_TO_VENDOR(
	paymentID int identity(1,1),
	amount decimal (10,2) not null,
	purchaseOrderId int not null,
	constraint [PK_PAYMENT_TO_VENDOR] primary key (paymentID),
	constraint [FK_PAYMENT_TO_VENDOR_PURCHASE_ORDER] foreign key(purchaseOrderID) references PURCHASE_ORDER(purchaseOrderID),
	constraint [CHK_amount] check (amount>0)

)

create table ITEM_RETURN(
	returnID int identity(1,1),
	salesOrderID int not null,
	upc bigInt not null,
	qtyReturned int not null,
	dateReturned as getDate(),
	constraint [PL_ITEM_RETURN] primary key(returnId),
	constraint [FK_ITEM_RETURN_SALES_ORDER_DETAIL] foreign key(salesOrderId,upc) references SALES_ORDER_DETAIL(salesOrderID, upc),
	constraint [CHK_qtyReturned] check (qtyReturned >0)
)




