// Minor update: Comment added for GitHub contributions
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    address public payer;       // فردی که پول را پرداخت می‌کند
    address public payee;       // فردی که پول را دریافت می‌کند
    address public escrowAgent; // شخص ثالث (ضامن)
    uint256 public amount;      // مقدار پرداختی

    bool public paymentCompleted; // وضعیت پرداخت

    event Deposit(address indexed payer, uint256 amount);
    event PaymentReleased(address indexed payee, uint256 amount);
    event RefundIssued(address indexed payer, uint256 amount);

    modifier onlyEscrowAgent() {
        require(msg.sender == escrowAgent, "Only the escrow agent can call this");
        _;
    }

    modifier onlyPayer() {
        require(msg.sender == payer, "Only the payer can call this");
        _;
    }

    modifier onlyPayee() {
        require(msg.sender == payee, "Only the payee can call this");
        _;
    }

    constructor(address _payee, uint256 _amount) {
        payer = msg.sender;
        payee = _payee;
        escrowAgent = msg.sender; // در ابتدا، خود پرداخت‌کننده به عنوان ضامن مشخص می‌شود
        amount = _amount;
        paymentCompleted = false;
    }

    // واریز مبلغ به قرارداد امانی
    function deposit() public payable onlyPayer {
        require(msg.value == amount, "Incorrect deposit amount");
        require(!paymentCompleted, "Payment already completed");

        emit Deposit(msg.sender, msg.value);
    }

    // تأیید پرداخت توسط ضامن و انتقال پول به گیرنده
    function releasePayment() public onlyEscrowAgent {
        require(!paymentCompleted, "Payment already completed");
        require(address(this).balance == amount, "Insufficient funds");

        paymentCompleted = true;
        payable(payee).transfer(amount);

        emit PaymentReleased(payee, amount);
    }

    // بازپرداخت پول به پرداخت‌کننده در صورت لغو معامله
    function refund() public onlyEscrowAgent {
        require(!paymentCompleted, "Payment already completed");
        require(address(this).balance == amount, "Insufficient funds");

        payable(payer).transfer(amount);

        emit RefundIssued(payer, amount);
    }

    // مشاهده موجودی قرارداد
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
