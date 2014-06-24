<%@ Page Title="About Us" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="About.aspx.cs" Inherits="Earthquakes.About" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h2>
        About
    </h2>
    <p>
        This page should call the GeoNames Recent Earthquake WebService
        using geonames with bounding dictated by the city entered.
    </p>
<p>
        This assignment is published by Chetan Badhe.</p>
</asp:Content>
