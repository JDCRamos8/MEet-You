﻿using System.Collections;
using Newtonsoft.Json.Linq;
using Pentaskilled.MEetAndYou.DataAccess;
using Pentaskilled.MEetAndYou.DataAccess.Implementation;
using Pentaskilled.MEetAndYou.Entities.DBModels;
using Pentaskilled.MEetAndYou.Entities.Models;
using Pentaskilled.MEetAndYou.Managers;
using Pentaskilled.MEetAndYou.Services.Implementation;
using SerpApi;

namespace Pentaskilled.MEetAndYou.TestingZone;
public class Program
{
    //public static void Main()
    //{
    //    //Console.WriteLine("THis is the current datetime: ");
    //    //Console.WriteLine(DateTime.UtcNow.ToString());

    //    //AuthnDAO authnDAO = new AuthnDAO();
    //    //AuthorizationDAO authzDAO = new AuthorizationDAO(); 
    //    //AuthnService authnService = new AuthnService();
    //    //AuthorizationManager authzController = new AuthorizationManager();
    //    //CopyItineraryDAO copyItinDAO = new CopyItineraryDAO();

    //    // Calling the method to save token to the databse, Brent ID
    //    //string token = "blueberrystrawberryy";
    //    //string brokenToken = "blu123rrystraw456ryy";
    //    //int userID = 4;
    //    //string claimedRole = "Admin";

    //    //bool result = authnDAO.SaveToken(userID, token).Result;
    //    //Console.WriteLine(result);

    //    //Console.WriteLine("");
    //    //Console.WriteLine("Verifying token: ");
    //    //bool isVerified = authzDAO.VerifyToken(userID, token);
    //    //Console.WriteLine("Result: " + isVerified);

    //    //Removing the token after verfication
    //    //Console.WriteLine("");
    //    //Console.WriteLine("Start removing token: ");
    //    //bool isDeleted = authnDAO.DeleteToken(userID).Result;
    //    //Console.WriteLine("Result: " + isDeleted);

    //    // Testing the Authorization Manager
    //    //Console.WriteLine("");
    //    //Console.WriteLine("Start verifying claimed role: ");
    //    //bool actualValue = authzController.IsAuthorized(userID, token, claimedRole);
    //    //Console.WriteLine("Result: " + actualValue);

    //    // Testing Itinerary DAO
    //    //Console.WriteLine("Before getting itin");
    //    //int itineraryID = 7;
    //    //Itinerary itinerary = copyItinDAO.GetItinerary(itineraryID).Result;
    //    //if (itinerary != null)
    //    //{
    //    //    Console.Write("Resulting itinerary: ");
    //    //    Console.WriteLine("ItinName: " + itinerary.ItineraryName);
    //    //}

    //    String apiKey = "";
    //    Hashtable ht = new Hashtable();
    //    ht.Add("engine", "google_events");
    //    ht.Add("q", "events in Long Beach");
    //    ht.Add("location", "Long Beach");

    //    try
    //    {
    //        GoogleSearch search = new GoogleSearch(ht, apiKey);
    //        JObject data = search.GetJson();
    //        JArray results = (JArray)data["organic_results"];
    //        foreach (JObject result in results)
    //        {
    //            Console.WriteLine("Found: " + result["title"]);
    //        }
    //    }
    //    catch(SerpApiSearchException ex)
    //    {
    //        Console.WriteLine("Exception:");
    //        Console.WriteLine(ex.ToString());
    //    }
    //}

    static void Main(string[] args)
    {
        // Testing Hyperlink DAO
        string testEmail = "jdcramos@gmail.com";

        HyperlinkDAO hyperlinkDAO = new HyperlinkDAO();

        Task<UserAccountRecordResponse> UARResponse = hyperlinkDAO.GetUserAccountRecordAsync(testEmail);

        if (UARResponse.Result.Data != null)
        {
            UserAccountRecord user = UARResponse.Result.Data;
            Console.WriteLine(UARResponse.Result.Message);

            Task<HyperlinkResponse> response = hyperlinkDAO.AddUserToItineraryAsync(user, 5, "View");
            //Task<HyperlinkResponse> response = hyperlinkDAO.RemoveUserFromItinerary(user, 5, "View");

            Console.WriteLine(response.Result.Message);
        }
        else
        {
            Console.WriteLine(UARResponse.Result.Message);
        }
    }
}