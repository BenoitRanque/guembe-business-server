(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["2d0dda1f"],{"81e5":function(a,n,i){"use strict";i.r(n);var e=function(){var a=this,n=a.$createElement,i=a._self._c||n;return i("q-page",{attrs:{padding:""}},[i("pre",[a._v(a._s(a.holiday))])])},t=[],d=i("967e"),r=i.n(d),o=(i("96cf"),i("fa84")),l=i.n(o),s={name:"Holiday",props:{holidayId:{type:String,required:!0}},data:function(){return{loading:!1,holiday:null}},methods:{loadHoliday:function(){var a=l()(r.a.mark(function a(){var n,i,e,t;return r.a.wrap(function(a){while(1)switch(a.prev=a.next){case 0:return n="query ($holiday_id: uuid!) {\n        holiday: calendar_holiday_by_pk (holiday_id: $holiday_id) {\n          holiday_id\n          name\n          date\n        }\n      }",i={holiday_id:this.holidayId},a.prev=2,this.loading=!0,a.next=6,this.$gql(n,i,{role:"administrator"});case 6:e=a.sent,t=e.holiday,this.holiday=t,a.next=14;break;case 11:a.prev=11,a.t0=a["catch"](2),this.$gql.handleError(a.t0);case 14:return a.prev=14,this.loading=!1,a.finish(14);case 17:case"end":return a.stop()}},a,this,[[2,11,14,17]])}));function n(){return a.apply(this,arguments)}return n}()},mounted:function(){this.loadHoliday()}},h=s,u=i("2877"),c=Object(u["a"])(h,e,t,!1,null,null,null);n["default"]=c.exports}}]);