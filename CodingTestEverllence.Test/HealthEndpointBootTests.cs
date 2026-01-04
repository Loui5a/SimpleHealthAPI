using System;
using System.Diagnostics;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Testing;
using NUnit.Framework;

namespace CodingTestEverllence.Test
{
    [TestFixture]
    public class HealthEndpointBootTests
    {
        [Test]
        public async Task Api_Boots_WithinOneMinute_HealthEndpointBecomesHealthy()
        {
            // Using WebApplicationFactory to host the application in-memory for testing.
            // If we expand, we might consider moving factory to [textfixture] for reuse across tests as maybe memory heavy to create multiple times.
            using var factory = new WebApplicationFactory<Program>();
            using var client = factory.CreateClient();

            var timeout = TimeSpan.FromMinutes(1);
            var pollInterval = TimeSpan.FromSeconds(1);
            var sw = Stopwatch.StartNew();

            HttpResponseMessage? lastResponse = null;
            bool becameHealthy = false;

            while (sw.Elapsed < timeout)
            {
                try
                {
                    lastResponse = await client.GetAsync("/health");
                    if (lastResponse.StatusCode == HttpStatusCode.OK)
                    {
                        becameHealthy = true;
                        break;
                    }
                }
                catch
                {
                    // Ignored - occasional connection errors while the server boots are expected.
                }

                await Task.Delay(pollInterval);
            }

            Assert.That(becameHealthy, Is.True, $"The health endpoint did not report healthy within {timeout.TotalSeconds} seconds. Last status: {lastResponse?.StatusCode.ToString() ?? "no response"}");
        }
    }
}