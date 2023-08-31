class BuilderResponse {
    AboutUs? aboutUs;
    String? address;
    String? appName;
    String?appSsImage;
    String? appStoreLink;
    List<ClientsReview>? clientsReview;
    String? companyName;
    String? contactEmail;
    String? contactNumber;
    ContactUs? contactUs;
    String? createOrderDescription;
    String? deliveryManImage;
    DeliveryPartner? deliveryPartner;
    String? downloadFooterContent;
    String? downloadText;
    String? facebookUrl;
    String? helpAndSupport;
    String? instagramUrl;
    String? linkedinUrl;
    String? playStoreLink;
    String? privacyPolicy;
    String? termAndCondition;
    String? purchaseUrl;
    String? twitterUrl;
    WhyChoose? whyChoose;

    BuilderResponse({this.aboutUs, this.address, this.appName, this.appSsImage, this.appStoreLink, this.clientsReview, this.companyName, this.contactEmail, this.contactNumber, this.contactUs, this.createOrderDescription, this.deliveryManImage, this.deliveryPartner, this.downloadFooterContent, this.downloadText, this.facebookUrl, this.helpAndSupport, this.instagramUrl, this.linkedinUrl, this.playStoreLink, this.privacyPolicy,this.termAndCondition, this.purchaseUrl, this.twitterUrl, this.whyChoose});

    factory BuilderResponse.fromJson(Map<String, dynamic> json) {
        return BuilderResponse(
            aboutUs: json['about_us'] != null ? AboutUs.fromJson(json['about_us']) : null, 
            address: json['address'], 
            appName: json['app_name'], 
            appSsImage: json['app_ss_image'], 
            appStoreLink: json['app_store_link'], 
            clientsReview: json['clients_review'] != null ? (json['clients_review'] as List).map((i) => ClientsReview.fromJson(i)).toList() : null, 
            companyName: json['company_name'], 
            contactEmail: json['contact_email'], 
            contactNumber: json['contact_number'], 
            contactUs: json['contact_us'] != null ? ContactUs.fromJson(json['contact_us']) : null, 
            createOrderDescription: json['create_order_description'], 
            deliveryManImage: json['delivery_man_image'], 
            deliveryPartner: json['delivery_partner'] != null ? DeliveryPartner.fromJson(json['delivery_partner']) : null, 
            downloadFooterContent: json['download_footer_content'],
            downloadText: json['download_text'], 
            facebookUrl: json['facebook_url'], 
            helpAndSupport: json['help_and_support'], 
            instagramUrl: json['instagram_url'], 
            linkedinUrl: json['linkedin_url'], 
            playStoreLink: json['play_store_link'], 
            privacyPolicy: json['privacy_policy'],
            termAndCondition: json['term_and_condition'],
            purchaseUrl: json['purchase_url'], 
            twitterUrl: json['twitter_url'], 
            whyChoose: json['why_choose'] != null ? WhyChoose.fromJson(json['why_choose']) : null, 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['address'] = this.address;
        data['app_name'] = this.appName;
        data['app_ss_image'] = this.appSsImage;
        data['app_store_link'] = this.appStoreLink;
        data['company_name'] = this.companyName;
        data['contact_email'] = this.contactEmail;
        data['contact_number'] = this.contactNumber;
        data['create_order_description'] = this.createOrderDescription;
        data['delivery_man_image'] = this.deliveryManImage;
        data['download_footer_content'] = this.downloadFooterContent;
        data['download_text'] = this.downloadText;
        data['facebook_url'] = this.facebookUrl;
        data['help_and_support'] = this.helpAndSupport;
        data['instagram_url'] = this.instagramUrl;
        data['linkedin_url'] = this.linkedinUrl;
        data['play_store_link'] = this.playStoreLink;
        data['privacy_policy'] = this.privacyPolicy;
        data['term_and_condition'] = this.termAndCondition;
        data['purchase_url'] = this.purchaseUrl;
        data['twitter_url'] = this.twitterUrl;
        if (this.aboutUs != null) {
            data['about_us'] = this.aboutUs!.toJson();
        }
        if (this.clientsReview != null) {
            data['clients_review'] = this.clientsReview!.map((v) => v.toJson()).toList();
        }
        if (this.contactUs != null) {
            data['contact_us'] = this.contactUs!.toJson();
        }
        if (this.deliveryPartner != null) {
            data['delivery_partner'] = this.deliveryPartner!.toJson();
        }
        if (this.whyChoose != null) {
            data['why_choose'] = this.whyChoose!.toJson();
        }
        return data;
    }
}

class ClientsReview {
    String? email;
    String? image;
    String? name;
    String? review;

    ClientsReview({this.email, this.image, this.name, this.review});

    factory ClientsReview.fromJson(Map<String, dynamic> json) {
        return ClientsReview(
            email: json['email'], 
            image: json['image'], 
            name: json['name'], 
            review: json['review'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['email'] = this.email;
        data['image'] = this.image;
        data['name'] = this.name;
        data['review'] = this.review;
        return data;
    }
}

class AboutUs {
    String? aboutUsAppSs;
    String? downloadSubtitle;
    String? downloadTitle;
    String? longDes;
    String? sortDes;

    AboutUs({this.aboutUsAppSs, this.downloadSubtitle, this.downloadTitle, this.longDes, this.sortDes});

    factory AboutUs.fromJson(Map<String, dynamic> json) {
        return AboutUs(
            aboutUsAppSs: json['about_us_app_ss'], 
            downloadSubtitle: json['download_subtitle'], 
            downloadTitle: json['download_title'], 
            longDes: json['long_des'], 
            sortDes: json['sort_des'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['about_us_app_ss'] = this.aboutUsAppSs;
        data['download_subtitle'] = this.downloadSubtitle;
        data['download_title'] = this.downloadTitle;
        data['long_des'] = this.longDes;
        data['sort_des'] = this.sortDes;
        return data;
    }
}

class ContactUs {
    String? contactSubtitle;
    String? contactTitle;
    String? contactUsAppSs;

    ContactUs({this.contactSubtitle, this.contactTitle,this.contactUsAppSs});

    factory ContactUs.fromJson(Map<String, dynamic> json) {
        return ContactUs(
            contactSubtitle: json['contact_subtitle'], 
            contactTitle: json['contact_title'],
            contactUsAppSs :json['contact_us_app_ss'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['contact_subtitle'] = this.contactSubtitle;
        data['contact_title'] = this.contactTitle;
        data['contact_us_app_ss'] = this.contactUsAppSs;
        return data;
    }
}

class WhyChoose {
    List<WhyChooseData>? data;
    String? description;

    WhyChoose({this.data, this.description});

    factory WhyChoose.fromJson(Map<String, dynamic> json) {
        return WhyChoose(
            data: json['data'] != null ? (json['data'] as List).map((i) => WhyChooseData.fromJson(i)).toList() : null,
            description: json['description'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['description'] = this.description;
        if (this.data != null) {
            data['data'] = this.data!.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class WhyChooseData {
    String? image;
    String? subtitle;
    String? title;

    WhyChooseData({this.image, this.subtitle, this.title});

    factory WhyChooseData.fromJson(Map<String, dynamic> json) {
        return WhyChooseData(
            image: json['image'], 
            subtitle: json['subtitle'], 
            title: json['title'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['image'] = this.image;
        data['subtitle'] = this.subtitle;
        data['title'] = this.title;
        return data;
    }
}

class DeliveryPartner {
    List<Benefit>? benefits;
    String? image;
    String? subtitle;
    String? title;

    DeliveryPartner({this.benefits, this.image, this.subtitle, this.title});

    factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
        return DeliveryPartner(
            benefits: json['benefits'] != null ? (json['benefits'] as List).map((i) => Benefit.fromJson(i)).toList() : null, 
            image: json['image'], 
            subtitle: json['subtitle'], 
            title: json['title'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['image'] = this.image;
        data['subtitle'] = this.subtitle;
        data['title'] = this.title;
        if (this.benefits != null) {
            data['benefits'] = this.benefits!.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class Benefit {
    String? image;
    String? subtitle;
    String? title;

    Benefit({this.image, this.subtitle, this.title});

    factory Benefit.fromJson(Map<String, dynamic> json) {
        return Benefit(
            image: json['image'], 
            subtitle: json['subtitle'], 
            title: json['title'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['image'] = this.image;
        data['subtitle'] = this.subtitle;
        data['title'] = this.title;
        return data;
    }
}