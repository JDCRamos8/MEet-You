﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Pentaskilled.MEetAndYou.Entities;

namespace Pentaskilled.MEetAndYou.Services.Contracts
{
    public interface IArchiverService
    {

        List<Log> GetOldLogs();

        bool ConsolidateOldLogs(List<Log> oldLogs);

        void Consolidate(List<Log> oldLogs, string buffLocation);

        bool CompressOldLogs();

        void Compress(string buffLocation, string archiveLocation);

        bool DeleteOldLogs(List<Log> oldLogs);



    }
}
