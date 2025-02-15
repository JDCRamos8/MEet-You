﻿using System.Linq;
using Microsoft.EntityFrameworkCore;
using Pentaskilled.MEetAndYou.DataAccess.Implementation;
using Pentaskilled.MEetAndYou.Entities.DBModels;

namespace Pentaskilled.MEetAndYou.Managers
{
    public class CopyManager
    {
        private readonly MEetAndYouDBContext _dbContext;
        private readonly CopyItineraryDAO _copyItineraryDAO;

        public CopyManager(MEetAndYouDBContext dBContext, CopyItineraryDAO copyItineraryDAO)
        {
            _dbContext = dBContext;
            _copyItineraryDAO = copyItineraryDAO;
        }

        public Itinerary LoadItineraryInfo(int itineraryID)
        {
            //Get the itinerary with that ID
            Itinerary itinerary = _copyItineraryDAO.GetItinerary(itineraryID).Result;

            //var itin2 =
            //    (from itin in _dbContext.Itineraries
            //     from e in _dbContext.Events
            //     select new { itin.ItineraryId, itin.ItineraryName, itin.Rating, e.EventId, e.EventName }).ToList();

            Itinerary itinEager =
                (from itin in _dbContext.Itineraries.Include("Users")
                 where itin.ItineraryId == itineraryID
                 select itin).FirstOrDefault<Itinerary>();

            //Itinerary itin5 =
            //     (from itin in _dbContext.Itineraries.Include("Users")
            //     where itin.ItineraryId == itineraryID
            //     select itin).FirstOrDefault<Itinerary>();

            //Get the list of events from the old itinerary
            //ICollection< Event > eventList = itinerary.Events;
            //ICollection<Image> imageList = itinerary.Images;

            //_dbContext.UserAccountRecords.FindAsync(3);
            //itinEager.Users.Remove(new UserAccountRecord());

            //Itinerary itin6 = new Itinerary();
            //_dbContext.Entry(itin6).State = EntityState.Modified;
            //_dbContext.SaveChanges();
            //List<UserAccountRecord> userList = itin5.Users.ToList();

            return itinerary;

        }
    }
}
