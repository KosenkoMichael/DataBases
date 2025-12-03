using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

public class BikeRentalContext : DbContext
{
    public DbSet<Model> Models => Set<Model>();
    public DbSet<RentalPoint> RentalPoints => Set<RentalPoint>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Bicycle> Bicycles => Set<Bicycle>();
    public DbSet<Rental> Rentals => Set<Rental>();

    public BikeRentalContext(DbContextOptions<BikeRentalContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Model>(e =>
        {
            e.ToTable("models");
            e.HasKey(x => x.ModelId);
            e.Property(x => x.ModelId).HasColumnName("model_id");
            e.Property(x => x.ModelTitle).HasColumnName("model_title");
        });

        b.Entity<RentalPoint>(e =>
        {
            e.ToTable("rental_points");
            e.HasKey(x => x.PointId);
            e.Property(x => x.PointId).HasColumnName("point_id");
            e.Property(x => x.PointTitle).HasColumnName("point_title");
            e.Property(x => x.Lat).HasColumnName("lat");
            e.Property(x => x.Lon).HasColumnName("lon");
            e.Property(x => x.Notes).HasColumnName("notes");
        });

        b.Entity<Customer>(e =>
        {
            e.ToTable("customers");
            e.HasKey(x => x.CustomerId);
            e.Property(x => x.CustomerId).HasColumnName("customer_id");
            e.Property(x => x.Passport).HasColumnName("passport");
            e.Property(x => x.FirstName).HasColumnName("first_name");
            e.Property(x => x.LastName).HasColumnName("last_name");
            e.Property(x => x.Phone).HasColumnName("phone");
        });

        b.Entity<Bicycle>(e =>
        {
            e.ToTable("bicycles");
            e.HasKey(x => x.BicycleId);
            e.Property(x => x.BicycleId).HasColumnName("bicycle_id");
            e.Property(x => x.SerialNumber).HasColumnName("serial_number");
            e.Property(x => x.ModelId).HasColumnName("model_id");
            e.HasOne(bi => bi.Model).WithMany(m => m.Bicycles).HasForeignKey(bi => bi.ModelId);
        });

        b.Entity<Rental>(e =>
        {
            e.ToTable("rental");
            e.HasKey(x => x.RentalId);
            e.Property(x => x.RentalId).HasColumnName("rental_id");
            e.Property(x => x.BicycleId).HasColumnName("bicycle_id");
            e.Property(x => x.CustomerId).HasColumnName("customer_id");
            e.Property(x => x.PickPointId).HasColumnName("pick_point_id");
            e.Property(x => x.ReturnPointId).HasColumnName("return_point_id");
            e.Property(x => x.StartTime).HasColumnName("start_time");
            e.Property(x => x.EndTime).HasColumnName("end_time");

            e.HasOne(r => r.Bicycle).WithMany(bi => bi.Rentals).HasForeignKey(r => r.BicycleId);
            e.HasOne(r => r.Customer).WithMany(c => c.Rentals).HasForeignKey(r => r.CustomerId);

            e.HasOne(r => r.PickPoint)
             .WithMany(p => p.PickRentals)
             .HasForeignKey(r => r.PickPointId)
             .OnDelete(DeleteBehavior.Restrict);

            e.HasOne(r => r.ReturnPoint)
             .WithMany(p => p.ReturnRentals)
             .HasForeignKey(r => r.ReturnPointId)
             .OnDelete(DeleteBehavior.Restrict);
        });
    }
}

public class Model
{
    public int ModelId { get; set; }
    public string ModelTitle { get; set; } = "";
    public List<Bicycle> Bicycles { get; set; } = new();
}

public class RentalPoint
{
    public int PointId { get; set; }
    public string PointTitle { get; set; } = "";
    public decimal Lat { get; set; }
    public decimal Lon { get; set; }
    public string? Notes { get; set; }
    public List<Rental> PickRentals { get; set; } = new();
    public List<Rental> ReturnRentals { get; set; } = new();
}

public class Customer
{
    public int CustomerId { get; set; }
    public string Passport { get; set; } = "";
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public string Phone { get; set; } = "";
    public List<Rental> Rentals { get; set; } = new();
}

public class Bicycle
{
    public int BicycleId { get; set; }
    public string SerialNumber { get; set; } = "";
    public int ModelId { get; set; }
    public Model Model { get; set; } = null!;
    public List<Rental> Rentals { get; set; } = new();
}

public class Rental
{
    public int RentalId { get; set; }
    public int BicycleId { get; set; }
    public int CustomerId { get; set; }
    public int PickPointId { get; set; }
    public int? ReturnPointId { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }

    public Bicycle Bicycle { get; set; } = null!;
    public Customer Customer { get; set; } = null!;
    public RentalPoint PickPoint { get; set; } = null!;
    public RentalPoint? ReturnPoint { get; set; }
}

public class Program
{
    public static async Task Main()
    {
        var config = new ConfigurationBuilder()
            .AddJsonFile("appsettings.json")
            .Build();

        var options = new DbContextOptionsBuilder<BikeRentalContext>()
            .UseMySql(
                config.GetConnectionString("BikeRental")!,
                new MySqlServerVersion(new Version(8, 0, 34))
            )
            .Options;

        using var db = new BikeRentalContext(options);

        var q1 = await db.Models
            .Select(m => new { m.ModelTitle, Count = m.Bicycles.Count })
            .ToListAsync();

        var q2 = await db.Rentals
            .Where(r => r.Bicycle.Model.ModelTitle == "Bianchi Oltre")
            .Select(r => new { r.PickPoint.PointId, r.PickPoint.PointTitle })
            .Distinct()
            .OrderBy(x => x.PointTitle)
            .ToListAsync();

        var q3 = await db.Rentals
            .Where(r => r.EndTime != null)
            .GroupBy(r => r.Bicycle.Model.ModelTitle)
            .Select(g => new
            {
                ModelTitle = g.Key,
                Duration = g.Sum(r => EF.Functions.DateDiffHour(r.StartTime, r.EndTime!.Value))
            })
            .OrderBy(x => x.Duration)
            .ToListAsync();

        var q4 = await db.RentalPoints
            .Select(p => new { p.PointTitle, Count = p.PickRentals.Count })
            .OrderBy(x => x.PointTitle)
            .ToListAsync();

        var maxRentals = await db.Rentals
            .GroupBy(r => r.CustomerId)
            .Select(g => g.Count())
            .MaxAsync();

        var q5 = await db.Customers
            .Where(c => c.Rentals.Count == maxRentals)
            .Select(c => new { c.FirstName, c.LastName, Count = c.Rentals.Count })
            .OrderBy(x => x.LastName)
            .ThenBy(x => x.FirstName)
            .ToListAsync();

        var q6 = await db.Customers
            .Select(c => new
            {
                c.FirstName,
                c.LastName,
                Avg = c.Rentals
                    .Where(r => r.EndTime != null)
                    .Average(r => (double)EF.Functions.DateDiffHour(r.StartTime, r.EndTime!.Value))
            })
            .Where(x => x.Avg > 3)
            .ToListAsync();

        Console.WriteLine("Query 1:");
        q1.ForEach(Console.WriteLine);

        Console.WriteLine("\nQuery 2:");
        q2.ForEach(Console.WriteLine);

        Console.WriteLine("\nQuery 3:");
        q3.ForEach(Console.WriteLine);

        Console.WriteLine("\nQuery 4:");
        q4.ForEach(Console.WriteLine);

        Console.WriteLine("\nQuery 5:");
        q5.ForEach(Console.WriteLine);

        Console.WriteLine("\nQuery 6:");
        q6.ForEach(Console.WriteLine);
    }
}