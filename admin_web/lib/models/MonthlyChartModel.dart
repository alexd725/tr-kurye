import 'DashboardModel.dart';

class MonthlyChartModel {
  Month? month;
  List<MonthlyOrderCount>? monthlyOrderCount;

  MonthlyChartModel({this.month, this.monthlyOrderCount});

  MonthlyChartModel.fromJson(Map<String, dynamic> json) {
    month = json['month'] != null ? new Month.fromJson(json['month']) : null;
    if (json['monthly_order_count'] != null) {
      monthlyOrderCount = <MonthlyOrderCount>[];
      json['monthly_order_count'].forEach((v) {
        monthlyOrderCount!.add(new MonthlyOrderCount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.month != null) {
      data['month'] = this.month!.toJson();
    }
    if (this.monthlyOrderCount != null) {
      data['monthly_order_count'] = this.monthlyOrderCount!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Month {
  String? monthStart;
  String? monthEnd;
  int? diff;

  Month({this.monthStart, this.monthEnd, this.diff});

  Month.fromJson(Map<String, dynamic> json) {
    monthStart = json['month_start'];
    monthEnd = json['month_end'];
    diff = json['diff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month_start'] = this.monthStart;
    data['month_end'] = this.monthEnd;
    data['diff'] = this.diff;
    return data;
  }
}

class MonthlyCancelPaymentChartModel {
  Month? month;

  List<MonthlyPaymentCompletedReport>? monthlyPaymentCancelledReport;

  MonthlyCancelPaymentChartModel({this.month, this.monthlyPaymentCancelledReport});

  MonthlyCancelPaymentChartModel.fromJson(Map<String, dynamic> json) {
    month = json['month'] != null ? new Month.fromJson(json['month']) : null;

    if (json['monthly_payment_cancelled_report'] != null) {
      monthlyPaymentCancelledReport = <MonthlyPaymentCompletedReport>[];
      json['monthly_payment_cancelled_report'].forEach((v) {
        monthlyPaymentCancelledReport!.add(new MonthlyPaymentCompletedReport.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.month != null) {
      data['month'] = this.month!.toJson();
    }

    if (this.monthlyPaymentCancelledReport != null) {
      data['monthly_payment_cancelled_report'] = this.monthlyPaymentCancelledReport!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class MonthlyCompletePaymentChartModel {
  Month? month;
  List<MonthlyPaymentCompletedReport>? monthlyPaymentCompletedReport;

  MonthlyCompletePaymentChartModel({this.month, this.monthlyPaymentCompletedReport});

  MonthlyCompletePaymentChartModel.fromJson(Map<String, dynamic> json) {
    month = json['month'] != null ? new Month.fromJson(json['month']) : null;

    if (json['monthly_payment_completed_report'] != null) {
      monthlyPaymentCompletedReport = <MonthlyPaymentCompletedReport>[];
      json['monthly_payment_completed_report'].forEach((v) {
        monthlyPaymentCompletedReport!.add(new MonthlyPaymentCompletedReport.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.month != null) {
      data['month'] = this.month!.toJson();
    }

    if (this.monthlyPaymentCompletedReport != null) {
      data['monthly_payment_completed_report'] = this.monthlyPaymentCompletedReport!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
