﻿using Pentaskilled.MEetAndYou.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pentaskilled.MEetAndYou.DataAccess
{
    public interface ILogDAO
    {
        bool PushLogToDB(SystemLog sysLog);
        bool PushLogToDB(UserLog userLog);
    }
}
