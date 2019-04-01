pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


contract Smart_Syndicate
{

mapping(address => string) profile;
mapping(uint => total_count) total_bidder;
mapping(address => account_details) wallet;

struct account_details
{
    uint limit;
    uint balance;
}

address la;
address borrower;

constructor (address _la,address _borrower) public{
    la =_la;
    borrower = _borrower;
}

loan_param[] total_request;

struct total_count
{
bid[] count;
bid[] final_count;
}
struct bid
{
uint amount_to_invest;
uint intrest_rate;
}
struct loan_param
{
uint request_no;
uint amount_request;
string name;
uint amount_received;
uint duration;
address addrOfBorrower;
uint contactNo;
uint noOfInstallments;
uint interest_rate_expectation;
bool approved_by_la;
uint256 backgrd_certificate;
uint256 aution_start_time;
uint installmentCounter;
uint la_share;
uint la_intrest;
}
event aution_start_time(uint _request_no,uint aution_start_time);
event Loan_Approved(uint _request_no);
event PaymentByInvestor(uint requestno, uint amount, address _investor);

function register_the_address(string _profile) public // can be called by borrow/LA/investor
{ 
profile[msg.sender]=_profile;
}

modifier OnlyLA(){
    require(la == msg.sender,"Only Lead Arranger can call this function");
    _;
}
function request_loan(uint _request_no,string _name,uint _amount_request,uint _duration,address _adrOfBorrower, uint _contact_no,uint _noOfInstallments,uint _interest_rate_expectation) public  //can be called by borrow
{
 loan_param memory _param;

_param.request_no=_request_no;
_param.amount_request=_amount_request;
_param.duration=_duration;
_param.name=_name;
_param.addrOfBorrower=_adrOfBorrower;
_param.contactNo= _contact_no;
_param.noOfInstallments = _noOfInstallments;
_param.interest_rate_expectation=_interest_rate_expectation;
_param.approved_by_la=false;
_param.backgrd_certificate=0;
_param.aution_start_time=0;
_param.amount_request=0;
_param.la_share=0;
_param.la_intrest=0;


total_request.push(_param)-1; //loan request pushed on the blockchain
}

function underwriter(uint _request_no,uint256 _backgrd_certificate,uint _la_share,uint _la_intrest) public OnlyLA returns(bool)
{
for(uint i=0;i<total_request.length;i++)
{
if(total_request[i].request_no==_request_no)
{
total_request[i].backgrd_certificate=_backgrd_certificate;
total_request[i].approved_by_la=true;
total_request[i].la_share=_la_share;
total_request[i].la_intrest=_la_intrest;
return true;
//emit Loan_Approved(_request_no);    // event to emit when loan is approved
break;
}
}
}

function auction_start(uint _request_no) public OnlyLA returns(string)
{
for(uint i=0;i<total_request.length;i++)
{
if(total_request[i].request_no==_request_no)
{
total_request[i].aution_start_time=Timestamp_call();
//emit aution_start_time(_request_no, total_request[i].aution_start_time);


//wallet[total_request[i].addrOfBorrower].balance=wallet[total_request[i].addrOfBorrower].balance + (total_request[i].la_share/100)*total_request[i].amount_request;
//wallet[la].balance=wallet[la].balance - (total_request[i].la_share/100)*total_request[i].amount_request;

return "Aution Started";

}
}
}


function Timestamp_call() private returns (uint256 time) //timestamp
{
    return now;
}

function place_bid(uint _request_no,uint _amount_to_invest,uint _intrest_rate) public returns (string)
{

    bid my_bid;
    if(_amount_to_invest>wallet[msg.sender].balance)
    {
        my_bid.amount_to_invest=_amount_to_invest;
        my_bid.intrest_rate=_intrest_rate;
        
        total_bidder[_request_no].count.push(my_bid) -1;
        return "Bid Placed Successfully";
    }
}

function stop_bidding(uint _request_no) public OnlyLA returns (string)
{
    // total_bidder[_request_no].count.length ;
    for(uint i=0; i<total_bidder[_request_no].count.length;i++)
    {
        //total_bidder[_request_no].final_count.push(total_bidder[_request_no].count[i]);
    }
    //la adds money after stoping stop_bidding
    address _borrower;
    uint _la_share;
    uint _req_money;
    for(uint j=0;j<total_request.length;j++)
    {
         if(total_request[j].request_no==_request_no)
         {
             _la_share=total_request[j].la_share;
             _borrower=total_request[j].addrOfBorrower;
             _req_money=total_request[j].amount_request;
             
            uint amount_la=(_la_share/100)*_req_money;
            total_request[j].amount_received= total_request[i].amount_received + amount_la;
            wallet[_borrower].balance=wallet[_borrower].balance + amount_la;
            wallet[msg.sender].balance=wallet[msg.sender].balance - amount_la;
    
             break;
         }
    }
   

}
function payment(uint _request_no,uint _amount) public returns(string)
{
for(uint i=0;i<total_request.length;i++)
{
if(total_request[i].request_no == _request_no)
{
total_request[i].amount_received= total_request[i].amount_received + _amount;
wallet[total_request[i].addrOfBorrower].balance=wallet[total_request[i].addrOfBorrower].balance+_amount;
wallet[msg.sender].balance=wallet[msg.sender].balance - _amount;

//emit PaymentByInvestor(_request_no, _amount, msg.sender);

}
}
}

function show_request_details(uint _request_no) public view returns(loan_param)
{
for(uint i=0;i<total_request.length;i++)
{
if(total_request[i].request_no == _request_no)
{
return total_request[i];
}
} 
}
function show_all_bids(uint _request_no) public view returns (total_count)
{
return total_bidder[_request_no];
}
 
function rePayment(uint _request_no, uint _amount) public{
       address _brower;
       
    for(uint i=0;i<total_request.length;i++)
    {
        if(total_request[i].request_no==_request_no)
        {
             _brower=total_request[i].addrOfBorrower;
             break;
        }
    }
    
    wallet[_brower].balance=wallet[_brower].balance - _amount;
    wallet[la].balance=wallet[la].balance+_amount;
    
        
    //to be done
}

/*
function pending_request_la_1() public view returns(uint[],uint[],string[],uint[])
{                                           

uint[] _request_no;
uint[] _amount_request;
string[] _name;
uint[] _amount_received;
uint[] _duration;
address[] _addrOfBorrower;
uint[] _noOfInstallments;
uint[] _interest_rate_expectation;
uint256[] _backgrd_certificate;
uint[] _installmentCounter;

  uint len=0;  
    for(uint i=0;i<total_request.length;i++)
    {
     if(total_request[i].approved_by_la!=true)
     {
         _request_no[len]=total_request[i].request_no;
         _amount_request[len]=total_request[i].amount_request;
         _name[len]=total_request[i].name;
         _amount_received[len]=total_request[i].amount_received;
         _duration[len]=total_request[i].duration;
         _addrOfBorrower[len]=total_request[i].addrOfBorrower;
         _noOfInstallments[len]=total_request[i].noOfInstallments;
         _interest_rate_expectation[len]=total_request[i].interest_rate_expectation;
         _backgrd_certificate[len]=total_request[i].backgrd_certificate;
         _installmentCounter[len]=total_request[i].installmentCounter;
         
     }
     return(_request_no,_amount_received,_name,_amount_received);
    }
}



function pending_request_la_2() public view returns(uint[],address[],uint[],uint[])
{                                          

uint[] _request_no;
uint[] _amount_request;
string[] _name;
uint[] _amount_received;
uint[] _duration;
address[] _addrOfBorrower;
uint[] _noOfInstallments;
uint[] _interest_rate_expectation;
uint256[] _backgrd_certificate;
uint[] _installmentCounter;

  uint len=0;  
    for(uint i=0;i<total_request.length;i++)
    {
     if(total_request[i].approved_by_la!=true)
     {
         _request_no[len]=total_request[i].request_no;
         _amount_request[len]=total_request[i].amount_request;
         _name[len]=total_request[i].name;
         _amount_received[len]=total_request[i].amount_received;
         _duration[len]=total_request[i].duration;
         _addrOfBorrower[len]=total_request[i].addrOfBorrower;
         _noOfInstallments[len]=total_request[i].noOfInstallments;
         _interest_rate_expectation[len]=total_request[i].interest_rate_expectation;
         _backgrd_certificate[len]=total_request[i].backgrd_certificate;
         _installmentCounter[len]=total_request[i].installmentCounter;
         
     }
     return(_duration,_addrOfBorrower,_noOfInstallments,_interest_rate_expectation);
    }
}


function pending_request_la_3() public view returns(uint256[],uint[])
{                                           

uint[] _request_no;
uint[] _amount_request;
string[] _name;
uint[] _amount_received;
uint[] _duration;
address[] _addrOfBorrower;
uint[] _noOfInstallments;
uint[] _interest_rate_expectation;
uint256[] _backgrd_certificate;
uint[] _installmentCounter;

  uint len=0;  
    for(uint i=0;i<total_request.length;i++)
    {
     if(total_request[i].approved_by_la!=true)
     {
         _request_no[len]=total_request[i].request_no;
         _amount_request[len]=total_request[i].amount_request;
         _name[len]=total_request[i].name;
         _amount_received[len]=total_request[i].amount_received;
         _duration[len]=total_request[i].duration;
         _addrOfBorrower[len]=total_request[i].addrOfBorrower;
         _noOfInstallments[len]=total_request[i].noOfInstallments;
         _interest_rate_expectation[len]=total_request[i].interest_rate_expectation;
         _backgrd_certificate[len]=total_request[i].backgrd_certificate;
         _installmentCounter[len]=total_request[i].installmentCounter;
         
     }
     return(_backgrd_certificate,_installmentCounter);
     //,_duration,_addrOfBorrower,_noOfInstallments,_interest_rate_expectation,
    }
}
*/
function balance_show(address adr) public view returns (uint)
{
    return wallet[adr].balance;
}


function limit_show(address adr) public view returns (uint)
{
    return wallet[adr].balance;
}


function add_balance_n_limit(uint _balance,uint _limit) public  returns(string)
{
    wallet[msg.sender].balance=_balance;
    wallet[msg.sender].limit=_limit;
}


}
