﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Pentaskilled.MEetAndYou.Services.Contracts;

namespace Pentaskilled.MEetAndYou.Services.Implementation
{
    public static class Validator
    {
        // A number is valid if it can be parsed and is greater than 0.
        public static bool IsValidNumber(int number)
        {
            bool isNumber;

            if (number > 0)
            {
                isNumber = true;
            }
            else // Input is a negative number
            {
                isNumber = false;
            }

            return isNumber;
        }

        // A number is valid if it falls in between the range of num1 & num2.
        public static bool IsValidRange(int value, int num1, int num2)
        {
            return (value >= num1 && value <= num2) || (value <= num2 && value >= num1);
        }

        public static bool IsValueNull(Object obj)
        {
            return obj.Equals(null);
        }

        // Uses regex to check for a valid email address
        public static bool IsValidEmail(string email)
        {
            return Regex.IsMatch(email, @"^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$");
        }

        // A string is valid if it contains only letters
        public static bool IsValidString(string s)
        {
            return Regex.IsMatch(s, @"^[a-zA-Z]+$") && (s.ToLower().Contains("view") || s.ToLower().Contains("edit"));
        }

        // An extensions is valid if it contains only these letters

        public static bool IsValidExtension(string s)
        {
            if (s.Contains("jpg") ){
                return true;
            }
            if (s.Contains("png"))
                return true;
            if (s.Contains("jpg"))
                return true;


            return false;
        }
    }
}
