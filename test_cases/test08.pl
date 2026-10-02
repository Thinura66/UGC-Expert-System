% test_cases/test08.pl
:- multifile test/5.
test(tc08, 'Bank payment without voucher', [payment_method-bank, voucher_uploaded-no],
     voucher_required, [r18]).
