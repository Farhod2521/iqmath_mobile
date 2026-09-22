import 'dart:convert';

PaymentDataResponse paymentDataResponseFromJson(String str) =>
    PaymentDataResponse.fromJson(json.decode(str));

String paymentDataResponseToJson(PaymentDataResponse data) =>
    json.encode(data.toJson());

class PaymentDataResponse {
    final PriceDetails priceDetails;
    final PaymentData paymentData;

    PaymentDataResponse({
        required this.priceDetails,
        required this.paymentData,
    });

    factory PaymentDataResponse.fromJson(Map<String, dynamic> json) =>
        PaymentDataResponse(
            priceDetails: PriceDetails.fromJson(json["price_details"]),
            paymentData: PaymentData.fromJson(json["payment_data"]),
        );

    Map<String, dynamic> toJson() => {
        "price_details": priceDetails.toJson(),
        "payment_data": paymentData.toJson(),
    };
}

// ----------------------------------------------------------

class PaymentData {
    final Data data;
    final bool success;

    PaymentData({
        required this.data,
        required this.success,
    });

    factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
        data: Data.fromJson(json["data"]),
        success: json["success"] ?? false,
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "success": success,
    };
}

// ----------------------------------------------------------

class Data {
    final num storeId;
    final DateTime updatedOn;
    final num amount;
    final String checkoutUrl;
    final String deeplink;
    final List<Ofd> ofd;
    final String uuid;
    final String shortLink;
    final String callbackUrl;
    final String invoiceId;
    final String returnUrl;
    final Payment? payment;
    final DateTime addedOn;

    Data({
        required this.storeId,
        required this.updatedOn,
        required this.amount,
        required this.checkoutUrl,
        required this.deeplink,
        required this.ofd,
        required this.uuid,
        required this.shortLink,
        required this.callbackUrl,
        required this.invoiceId,
        required this.returnUrl,
        required this.payment,
        required this.addedOn,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        storeId: json["store_id"] ?? 0,
        updatedOn: DateTime.parse(json["updated_on"]),
        amount: json["amount"] ?? 0,
        checkoutUrl: json["checkout_url"],
        deeplink: json["deeplink"] ?? "",
        ofd: (json["ofd"] as List).map((x) => Ofd.fromJson(x)).toList(),
        uuid: json["uuid"],
        shortLink: json["short_link"],
        callbackUrl: json["callback_url"],
        invoiceId: json["invoice_id"],
        returnUrl: json["return_url"],
        payment:
        json["payment"] != null ? Payment.fromJson(json["payment"]) : null,
        addedOn: DateTime.parse(json["added_on"]),
    );

    Map<String, dynamic> toJson() => {
        "store_id": storeId,
        "updated_on": updatedOn.toIso8601String(),
        "amount": amount,
        "checkout_url": checkoutUrl,
        "deeplink": deeplink,
        "ofd": ofd.map((x) => x.toJson()).toList(),
        "uuid": uuid,
        "short_link": shortLink,
        "callback_url": callbackUrl,
        "invoice_id": invoiceId,
        "return_url": returnUrl,
        "payment": payment?.toJson(),
        "added_on": addedOn.toIso8601String(),
    };
}

// ----------------------------------------------------------

class Payment {
    final String uuid;
    final String callbackUrl;
    final String storeInvoiceId;
    final num id;
    final DateTime addedOn;
    final num storeId;
    final num commissionAmount;
    final num paymentAmount;
    final Store store;
    final List<Ofd> ofd;
    final Application application;
    final Data invoice;
    final String status;

    Payment({
        required this.uuid,
        required this.callbackUrl,
        required this.storeInvoiceId,
        required this.id,
        required this.addedOn,
        required this.storeId,
        required this.commissionAmount,
        required this.paymentAmount,
        required this.store,
        required this.ofd,
        required this.application,
        required this.invoice,
        required this.status,
    });

    factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        uuid: json["uuid"],
        callbackUrl: json["callback_url"],
        storeInvoiceId: json["store_invoice_id"],
        id: json["id"],
        addedOn: DateTime.parse(json["added_on"]),
        storeId: json["store_id"],
        commissionAmount: json["commission_amount"],
        paymentAmount: json["payment_amount"],
        store: Store.fromJson(json["store"]),
        ofd: (json["ofd"] as List).map((x) => Ofd.fromJson(x)).toList(),
        application: Application.fromJson(json["application"]),
        invoice: Data.fromJson(json["invoice"]),
        status: json["status"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "callback_url": callbackUrl,
        "store_invoice_id": storeInvoiceId,
        "id": id,
        "added_on": addedOn.toIso8601String(),
        "store_id": storeId,
        "commission_amount": commissionAmount,
        "payment_amount": paymentAmount,
        "store": store.toJson(),
        "ofd": ofd.map((x) => x.toJson()).toList(),
        "application": application.toJson(),
        "invoice": invoice.toJson(),
        "status": status,
    };
}

// ----------------------------------------------------------

class Ofd {
    final num packageCode;
    final num total;
    final num price;
    final num qty;
    final num vat;
    final String name;
    final String mxik;

    Ofd({
        required this.packageCode,
        required this.total,
        required this.price,
        required this.qty,
        required this.vat,
        required this.name,
        required this.mxik,
    });

    factory Ofd.fromJson(Map<String, dynamic> json) => Ofd(
        packageCode: json["package_code"],
        total: json["total"],
        price: json["price"],
        qty: json["qty"],
        vat: json["vat"],
        name: json["name"],
        mxik: json["mxik"],
    );

    Map<String, dynamic> toJson() => {
        "package_code": packageCode,
        "total": total,
        "price": price,
        "qty": qty,
        "vat": vat,
        "name": name,
        "mxik": mxik,
    };
}

// ----------------------------------------------------------

class Application {
    final num otpLength;
    final num walletOverdraft;
    final num otpRequired;
    final String applicationId;
    final num allowBalance;
    final num allowBankTransaction;
    final num id;
    final DateTime addedOn;

    Application({
        required this.otpLength,
        required this.walletOverdraft,
        required this.otpRequired,
        required this.applicationId,
        required this.allowBalance,
        required this.allowBankTransaction,
        required this.id,
        required this.addedOn,
    });

    factory Application.fromJson(Map<String, dynamic> json) => Application(
        otpLength: json["otp_length"],
        walletOverdraft: json["wallet_overdraft"],
        otpRequired: json["otp_required"],
        applicationId: json["application_id"],
        allowBalance: json["allow_balance"],
        allowBankTransaction: json["allow_bank_transaction"],
        id: json["id"],
        addedOn: DateTime.parse(json["added_on"]),
    );

    Map<String, dynamic> toJson() => {
        "otp_length": otpLength,
        "wallet_overdraft": walletOverdraft,
        "otp_required": otpRequired,
        "application_id": applicationId,
        "allow_balance": allowBalance,
        "allow_bank_transaction": allowBankTransaction,
        "id": id,
        "added_on": addedOn.toIso8601String(),
    };
}

// ----------------------------------------------------------

class Store {
    final Map<String, num> surcharge;
    final String note;
    final Contract contract;
    final num active;
    final Merchant merchant;
    final Map<String, num> discount;
    final String callbackClass;
    final num merchantId;
    final String title;
    final String uuid;
    final num cashback;
    final String taxPackageCode;
    final String taxCommissionRecipientTin;
    final MerchantAccount merchantAccount;
    final num taxRegistration;
    final String logo;
    final List<ViewField> viewFields;
    final String taxMxik;
    final num id;

    Store({
        required this.surcharge,
        required this.note,
        required this.contract,
        required this.active,
        required this.merchant,
        required this.discount,
        required this.callbackClass,
        required this.merchantId,
        required this.title,
        required this.uuid,
        required this.cashback,
        required this.taxPackageCode,
        required this.taxCommissionRecipientTin,
        required this.merchantAccount,
        required this.taxRegistration,
        required this.logo,
        required this.viewFields,
        required this.taxMxik,
        required this.id,
    });

    factory Store.fromJson(Map<String, dynamic> json) => Store(
        surcharge: Map.from(json["surcharge"]).map(
                (k, v) => MapEntry<String, num>(k, v is num ? v : num.parse(v))),
        note: json["note"],
        contract: Contract.fromJson(json["contract"]),
        active: json["active"],
        merchant: Merchant.fromJson(json["merchant"]),
        discount: Map.from(json["discount"]).map(
                (k, v) => MapEntry<String, num>(k, v is num ? v : num.parse(v))),
        callbackClass: json["callback_class"],
        merchantId: json["merchant_id"],
        title: json["title"],
        uuid: json["uuid"],
        cashback: json["cashback"],
        taxPackageCode: json["tax_package_code"],
        taxCommissionRecipientTin: json["tax_commission_recipient_tin"],
        merchantAccount: MerchantAccount.fromJson(json["merchant_account"]),
        taxRegistration: json["tax_registration"],
        logo: json["logo"],
        viewFields: (json["view_fields"] as List)
            .map((x) => ViewField.fromJson(x))
            .toList(),
        taxMxik: json["tax_mxik"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "surcharge": surcharge,
        "note": note,
        "contract": contract.toJson(),
        "active": active,
        "merchant": merchant.toJson(),
        "discount": discount,
        "callback_class": callbackClass,
        "merchant_id": merchantId,
        "title": title,
        "uuid": uuid,
        "cashback": cashback,
        "tax_package_code": taxPackageCode,
        "tax_commission_recipient_tin": taxCommissionRecipientTin,
        "merchant_account": merchantAccount.toJson(),
        "tax_registration": taxRegistration,
        "logo": logo,
        "view_fields": viewFields.map((x) => x.toJson()).toList(),
        "tax_mxik": taxMxik,
        "id": id,
    };
}

// ----------------------------------------------------------

class Contract {
    final DateTime date;
    final String edmStatus;
    final String edmDocumentId;
    final String service;
    final String numValue;
    final Fee fee;
    final num id;
    final num merchantId;

    Contract({
        required this.date,
        required this.edmStatus,
        required this.edmDocumentId,
        required this.service,
        required this.numValue,
        required this.fee,
        required this.id,
        required this.merchantId,
    });

    factory Contract.fromJson(Map<String, dynamic> json) => Contract(
        date: DateTime.parse(json["date"]),
        edmStatus: json["edm_status"],
        edmDocumentId: json["edm_document_id"],
        service: json["service"],
        numValue: json["num"],
        fee: Fee.fromJson(json["fee"]),
        id: json["id"],
        merchantId: json["merchant_id"],
    );

    Map<String, dynamic> toJson() => {
        "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "edm_status": edmStatus,
        "edm_document_id": edmDocumentId,
        "service": service,
        "num": numValue,
        "fee": fee.toJson(),
        "id": id,
        "merchant_id": merchantId,
    };
}

// ----------------------------------------------------------

class Fee {
    final num up;
    final String down;

    Fee({
        required this.up,
        required this.down,
    });

    factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        up: json["up"],
        down: json["down"],
    );

    Map<String, dynamic> toJson() => {
        "up": up,
        "down": down,
    };
}

// ----------------------------------------------------------

class Merchant {
    final num clearingOverall;
    final String contractId;
    final SenderAccount senderAccount;
    final String name;
    final String tin;
    final num id;
    final String bankAccount;

    Merchant({
        required this.clearingOverall,
        required this.contractId,
        required this.senderAccount,
        required this.name,
        required this.tin,
        required this.id,
        required this.bankAccount,
    });

    factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
        clearingOverall: json["clearing_overall"],
        contractId: json["contract_id"],
        senderAccount: SenderAccount.fromJson(json["sender_account"]),
        name: json["name"],
        tin: json["tin"],
        id: json["id"],
        bankAccount: json["bank_account"],
    );

    Map<String, dynamic> toJson() => {
        "clearing_overall": clearingOverall,
        "contract_id": contractId,
        "sender_account": senderAccount.toJson(),
        "name": name,
        "tin": tin,
        "id": id,
        "bank_account": bankAccount,
    };
}

// ----------------------------------------------------------

class SenderAccount {
    final String psExternalFeeType;
    final String abs;
    final String edmDocumentId;
    final String psExternalFeeAmount;
    final String sbpTerminalId;
    final bool disableHistory;

    SenderAccount({
        required this.psExternalFeeType,
        required this.abs,
        required this.edmDocumentId,
        required this.psExternalFeeAmount,
        required this.sbpTerminalId,
        required this.disableHistory,
    });

    factory SenderAccount.fromJson(Map<String, dynamic> json) => SenderAccount(
        psExternalFeeType: json["ps_external_fee_type"],
        abs: json["abs"],
        edmDocumentId: json["edm_document_id"],
        psExternalFeeAmount: json["ps_external_fee_amount"],
        sbpTerminalId: json["sbp_terminal_id"],
        disableHistory: json["disable_history"],
    );

    Map<String, dynamic> toJson() => {
        "ps_external_fee_type": psExternalFeeType,
        "abs": abs,
        "edm_document_id": edmDocumentId,
        "ps_external_fee_amount": psExternalFeeAmount,
        "sbp_terminal_id": sbpTerminalId,
        "disable_history": disableHistory,
    };
}

// ----------------------------------------------------------

class MerchantAccount {
    final String officialName;
    final String address;
    final String director;
    final bool isCommitent;
    final String directorPinfl;
    final bool active;
    final String uuid;
    final String accountNo;
    final String mfo;
    final String tin;
    final num id;
    final bool vatPayer;

    MerchantAccount({
        required this.officialName,
        required this.address,
        required this.director,
        required this.isCommitent,
        required this.directorPinfl,
        required this.active,
        required this.uuid,
        required this.accountNo,
        required this.mfo,
        required this.tin,
        required this.id,
        required this.vatPayer,
    });

    factory MerchantAccount.fromJson(Map<String, dynamic> json) =>
        MerchantAccount(
            officialName: json["official_name"],
            address: json["address"],
            director: json["director"],
            isCommitent: json["is_commitent"],
            directorPinfl: json["director_pinfl"],
            active: json["active"],
            uuid: json["uuid"],
            accountNo: json["account_no"],
            mfo: json["mfo"],
            tin: json["tin"],
            id: json["id"],
            vatPayer: json["vat_payer"],
        );

    Map<String, dynamic> toJson() => {
        "official_name": officialName,
        "address": address,
        "director": director,
        "is_commitent": isCommitent,
        "director_pinfl": directorPinfl,
        "active": active,
        "uuid": uuid,
        "account_no": accountNo,
        "mfo": mfo,
        "tin": tin,
        "id": id,
        "vat_payer": vatPayer,
    };
}

// ----------------------------------------------------------

class ViewField {
    final String name;
    final bool? excludeFromInvoice;
    final String type;
    final String? value;
    final String? label;
    final num? order;

    ViewField({
        required this.name,
        this.excludeFromInvoice,
        required this.type,
        this.value,
        this.label,
        this.order,
    });

    factory ViewField.fromJson(Map<String, dynamic> json) => ViewField(
        name: json["name"],
        excludeFromInvoice: json["excludeFromInvoice"],
        type: json["type"],
        value: json["value"],
        label: json["label"],
        order: json["order"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "excludeFromInvoice": excludeFromInvoice,
        "type": type,
        "value": value,
        "label": label,
        "order": order,
    };
}

// ----------------------------------------------------------

class PriceDetails {
    final num subscriptionMonths;
    final num originalPrice;
    final CashbackDetails cashbackDetails;
    final String subscriptionName;
    final num discountPercent;
    final num salePrice;

    PriceDetails({
        required this.subscriptionMonths,
        required this.originalPrice,
        required this.cashbackDetails,
        required this.subscriptionName,
        required this.discountPercent,
        required this.salePrice,
    });

    factory PriceDetails.fromJson(Map<String, dynamic> json) => PriceDetails(
        subscriptionMonths: json["subscription_months"],
        originalPrice: json["original_price"],
        cashbackDetails: CashbackDetails.fromJson(json["cashback_details"]),
        subscriptionName: json["subscription_name"],
        discountPercent: json["discount_percent"],
        salePrice: json["sale_price"],
    );

    Map<String, dynamic> toJson() => {
        "subscription_months": subscriptionMonths,
        "original_price": originalPrice,
        "cashback_details": cashbackDetails.toJson(),
        "subscription_name": subscriptionName,
        "discount_percent": discountPercent,
        "sale_price": salePrice,
    };
}

// ----------------------------------------------------------

class CashbackDetails {
    final num teacherCashback;
    final num studentCashback;

    CashbackDetails({
        required this.teacherCashback,
        required this.studentCashback,
    });

    factory CashbackDetails.fromJson(Map<String, dynamic> json) =>
        CashbackDetails(
            teacherCashback: json["teacher_cashback"],
            studentCashback: json["student_cashback"],
        );

    Map<String, dynamic> toJson() => {
        "teacher_cashback": teacherCashback,
        "student_cashback": studentCashback,
    };
}
