(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["e748deb0"],{4390:function(t,e,n){"use strict";var i=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("q-card",t._b({attrs:{flat:""}},"q-card",t.$attrs,!1),[t._t("header"),n("q-card-section",{staticClass:"text-subtitle2 row"},[t._v("\n    "+t._s(t.listing.public_name)+"\n    "),n("q-space"),t._v("\n    Bs "+t._s(t.listing.listing_products.reduce(function(t,e){var n=e.price,i=e.quantity;return t+n/100*i},0).toFixed(2))+"\n  ")],1),n("q-card-section",{staticClass:"text-caption"},[t._v("\n    "+t._s(t.listing.description)+"\n  ")]),n("q-card-section",{staticClass:"q-px-none"},[n("q-expansion-item",{attrs:{dense:"",label:"Detalles","dense-toggle":"","default-opened":""},scopedSlots:t._u([{key:"header",fn:function(){return[n("q-item-section",[n("q-item-label",{attrs:{caption:""}},[t._v("\n            Mostrar Detalles\n          ")])],1)]},proxy:!0}])},[n("q-markup-table",{attrs:{separator:"none","wrap-cells":"",flat:"",dense:""}},[n("thead",[n("tr",[n("th",{staticClass:"text-left"},[t._v("Producto Incluido")]),n("th",{staticClass:"text-right"},[t._v("Precio Unitario")]),n("th",{staticClass:"text-right"},[t._v("Cantidad")]),n("th",{staticClass:"text-right"},[t._v("Subtotal")])])]),n("tbody",t._l(t.listing.listing_products,function(e,i){return n("tr",{key:i},[n("td",[n("div",{staticClass:"text-body2"},[t._v("\n                "+t._s(e.product.public_name)+"\n              ")]),n("div",{staticClass:"text-caption"},[t._v("\n                "+t._s(e.product.description)+"\n              ")]),n("lifetime-display",{attrs:{lifetime:e.lifetime}})],1),n("td",{staticClass:"text-right"},[t._v("Bs "+t._s((e.price/100).toFixed(2)))]),n("td",{staticClass:"text-right"},[t._v(t._s(e.quantity))]),n("td",{staticClass:"text-right"},[t._v("Bs "+t._s((e.price/100*e.quantity).toFixed(2)))])])}),0)])],1)],1),t._t("footer")],2)},s=[],a=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",{staticClass:"text-caption cursor-pointer",nativeOn:{click:function(e){t.show=!t.show}}},[t._v("\n  "+t._s(t.lifetime.public_name)+"\n  "),n("q-icon",{attrs:{name:"mdi-information"}},[n("q-tooltip",[t._v("\n      Haz click para mas detalles\n    ")])],1),n("q-menu",{model:{value:t.show,callback:function(e){t.show=e},expression:"show"}},[n("q-card",[n("q-card-section",[t._v("\n        "+t._s(t.lifetime.public_name)+"\n      ")]),n("q-card-section",[t._v("\n        "+t._s(t.lifetime.description)+"\n      ")]),n("q-card-section",[t._v("\n        "+t._s(t.lifetime.start)+"\n        -\n        "+t._s(t.lifetime.end)+"\n      ")]),n("q-card-section",[t._v("\n        "+t._s(t.lifetime.lifetime_weekdays.map(function(t){var e=t.weekday.description;return e}).join(", "))+"\n      ")])],1)],1)],1)},r=[],c={name:"LifetimeDisplay",props:{lifetime:{required:!0,type:Object}},data:function(){return{show:!1}}},o=c,u=n("2877"),l=Object(u["a"])(o,a,r,!1,null,null,null),p=l.exports,d={name:"ListingDisplay",components:{LifetimeDisplay:p},props:{listing:{type:Object,required:!0}}},_=d,h=Object(u["a"])(_,i,s,!1,null,null,null);e["a"]=h.exports},"6b8a":function(t,e,n){"use strict";n.r(e);var i=function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("q-page",{attrs:{padding:""}},[t.purchase?[t._v("\n    Razon Social: "+t._s(t.purchase.buyer_business_name)+" "),n("br"),t._v("\n    NIT: "+t._s(t.purchase.buyer_tax_identification_number)+" "),n("br"),t._v("\n    Estado de pago: "+t._s(t.purchase.payment.payment_status.description)+"\n    "),"PENDING"===t.purchase.payment.status?[n("q-btn",{attrs:{flat:"",label:"Verificar Estado de pago"},on:{click:function(e){return t.verifyPaymentStatus(t.purchase.payment.payment_id)}}}),n("br")]:t._e(),n("div",{staticClass:"text-subtitle2"},[t._v("\n      Facturas\n    ")]),t._l(t.purchase.invoices,function(e,i){var s=e.izi_link;return n("a",{key:"invoice_"+i,attrs:{download:"",href:s}},[t._v("Factura "+t._s(i+1))])}),t._l(t.purchase.purchase_listings,function(t,e){var i=t.listing;return n("listing-display",{key:e,staticClass:"q-my-md",attrs:{listing:i}})})]:t._e(),n("pre",[t._v(t._s(t.purchase))]),n("q-inner-loading",{attrs:{showing:t.loading}},[n("q-spinner")],1)],2)},s=[],a=n("967e"),r=n.n(a),c=(n("96cf"),n("fa84")),o=n.n(c),u=n("4390"),l={name:"Purchase",components:{ListingDisplay:u["a"]},props:{PurchaseId:{type:String,required:!0}},data:function(){return{loading:!1,purchase:null}},methods:{verifyPaymentStatus:function(){var t=o()(r.a.mark(function t(e){return r.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,this.loading=!0,t.next=4,this.$api.post("/store/verifypayment/".concat(e));case 4:t.next=9;break;case 6:t.prev=6,t.t0=t["catch"](0),this.$gql.handleError(t.t0);case 9:return t.prev=9,this.loading=!1,this.loadPurchase(),t.finish(9);case 13:case"end":return t.stop()}},t,this,[[0,6,9,13]])}));function e(e){return t.apply(this,arguments)}return e}(),loadPurchase:function(){var t=o()(r.a.mark(function t(){var e,n,i,s;return r.a.wrap(function(t){while(1)switch(t.prev=t.next){case 0:return e="\n        query getPurchases ($purchase_id: uuid!) {\n          purchase: store_purchase_by_pk (purchase_id: $purchase_id) {\n            buyer_business_name\n            buyer_tax_identification_number\n            payment {\n              payment_id\n              status\n              payment_status {\n                description\n              }\n            }\n            invoices {\n              izi_link\n              izi_timestamp\n            }\n            purchase_listings {\n              quantity\n              listing {\n                listing_id\n                public_name\n                description\n                listing_products {\n                  product {\n                    public_name\n                    description\n                  }\n                  quantity\n                  price\n                  lifetime {\n                    public_name\n                    description\n                    start\n                    end\n                    lifetime_weekdays (order_by: [{weekday: { weekday_id: asc } }]) {\n                      weekday {\n                        weekday_id\n                        description\n                      }\n                    }\n                  }\n                }\n              }\n            }\n            purchased_products {\n              product {\n                public_name\n                description\n              }\n              lifetime {\n                description\n              }\n            }\n          }\n        }\n      ",n={purchase_id:this.PurchaseId},t.prev=2,this.loading=!0,t.next=6,this.$gql(e,n);case 6:i=t.sent,s=i.purchase,this.purchase=s,t.next=14;break;case 11:t.prev=11,t.t0=t["catch"](2),this.$gql.handleError(t.t0);case 14:return t.prev=14,this.loading=!1,t.finish(14);case 17:case"end":return t.stop()}},t,this,[[2,11,14,17]])}));function e(){return t.apply(this,arguments)}return e}()},mounted:function(){this.loadPurchase()}},p=l,d=n("2877"),_=Object(d["a"])(p,i,s,!1,null,null,null);e["default"]=_.exports}}]);