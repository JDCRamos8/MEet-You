﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Pentaskilled.MEetAndYou.DataAccess.Contracts;
using Pentaskilled.MEetAndYou.Entities.DBModels;

namespace Pentaskilled.MEetAndYou.DataAccess.Implementation
{
    public class UserDAO : IUserDAO

    {
        private MEetAndYouDBContext _dbContext;
        

        public UserDAO(MEetAndYouDBContext _dbContext)
        {
            this._dbContext = _dbContext;
        }


        public async Task<UserAccountRecord> getUserAccount(int userID)
        {
            UserAccountRecord userRecord = await _dbContext.UserAccountRecords.FindAsync(userID);
            return userRecord;
        }
    }
}
