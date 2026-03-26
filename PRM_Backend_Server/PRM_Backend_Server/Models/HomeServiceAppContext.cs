using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace PRM_Backend_Server.Models;

public partial class HomeServiceAppContext : DbContext
{
    public HomeServiceAppContext()
    {
    }

    public HomeServiceAppContext(DbContextOptions<HomeServiceAppContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Booking> Bookings { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Rating> Ratings { get; set; }

    public virtual DbSet<ServiceCategory> ServiceCategories { get; set; }

    public virtual DbSet<ServicePackage> ServicePackages { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<ViewBookingDetail> ViewBookingDetails { get; set; }

    public virtual DbSet<Worker> Workers { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        var builder = new ConfigurationBuilder();
        builder.SetBasePath(Directory.GetCurrentDirectory());
        builder.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
        var configuration = builder.Build();
        optionsBuilder.UseSqlServer(configuration.GetConnectionString("MyCnn"));
    }


    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasKey(e => e.BookingId).HasName("PK__Bookings__73951AED9CE513DF");

            entity.HasIndex(e => e.CustomerId, "IX_Booking_Customer");

            entity.HasIndex(e => e.Status, "IX_Booking_Status");

            entity.HasIndex(e => e.WorkerId, "IX_Booking_Worker");

            entity.HasIndex(e => e.BookingCode, "UQ__Bookings__C6E56BD518F8BC89").IsUnique();

            entity.Property(e => e.BookingCode).HasMaxLength(20);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .HasDefaultValue("pending");
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.Customer).WithMany(p => p.BookingCustomers)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Booking_Customer");

            entity.HasOne(d => d.Package).WithMany(p => p.Bookings)
                .HasForeignKey(d => d.PackageId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Booking_Package");

            entity.HasOne(d => d.Worker).WithMany(p => p.BookingWorkers)
                .HasForeignKey(d => d.WorkerId)
                .HasConstraintName("FK_Booking_Worker");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.PaymentId).HasName("PK__Payments__9B556A38184C652B");

            entity.Property(e => e.PaymentMethod).HasMaxLength(20);
            entity.Property(e => e.PaymentStatus)
                .HasMaxLength(20)
                .HasDefaultValue("pending");
            entity.Property(e => e.TransactionCode).HasMaxLength(100);

            entity.HasOne(d => d.Booking).WithMany(p => p.Payments)
                .HasForeignKey(d => d.BookingId)
                .HasConstraintName("FK_Payment_Booking");
        });

        modelBuilder.Entity<Rating>(entity =>
        {
            entity.HasKey(e => e.RatingId).HasName("PK__Ratings__FCCDF87C3C697638");

            entity.ToTable(tb => tb.HasTrigger("TR_UpdateWorkerRating"));

            entity.HasIndex(e => e.WorkerId, "IX_Rating_Worker");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");

            entity.HasOne(d => d.Booking).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.BookingId)
                .HasConstraintName("FK_Rating_Booking");

            entity.HasOne(d => d.Customer).WithMany(p => p.RatingCustomers)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Rating_Customer");

            entity.HasOne(d => d.Worker).WithMany(p => p.RatingWorkers)
                .HasForeignKey(d => d.WorkerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Rating_Worker");
        });

        modelBuilder.Entity<ServiceCategory>(entity =>
        {
            entity.HasKey(e => e.CategoryId).HasName("PK__ServiceC__19093A0BEB67DC4E");

            entity.Property(e => e.CategoryName).HasMaxLength(100);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
        });

        modelBuilder.Entity<ServicePackage>(entity =>
        {
            entity.HasKey(e => e.PackageId).HasName("PK__ServiceP__322035CC82A1EC19");

            entity.HasIndex(e => e.CategoryId, "IX_Package_Category");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PackageName).HasMaxLength(100);
            entity.Property(e => e.Price).HasColumnType("decimal(12, 2)");

            entity.HasOne(d => d.Category).WithMany(p => p.ServicePackages)
                .HasForeignKey(d => d.CategoryId)
                .HasConstraintName("FK_Package_Category");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__Users__1788CC4CFD6C195C");

            entity.HasIndex(e => e.Role, "IX_Users_Role");

            entity.HasIndex(e => e.Phone, "UQ__Users__5C7E359E914481F9").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Users__A9D10534109F8ED2").IsUnique();

            entity.Property(e => e.Avatar).HasMaxLength(255);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysdatetime())");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Role)
                .HasMaxLength(20)
                .HasDefaultValue("customer");
            entity.Property(e => e.RefreshToken).HasMaxLength(255);
            entity.Property(e => e.RefreshTokenExpirationTime).HasColumnType("datetime2");
            entity.Property(e => e.UpdatedAt).HasDefaultValueSql("(sysdatetime())");
        });

        modelBuilder.Entity<ViewBookingDetail>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("ViewBookingDetail");

            entity.Property(e => e.BookingCode).HasMaxLength(20);
            entity.Property(e => e.CustomerName).HasMaxLength(100);
            entity.Property(e => e.PackageName).HasMaxLength(100);
            entity.Property(e => e.Price).HasColumnType("decimal(12, 2)");
            entity.Property(e => e.Status).HasMaxLength(20);
            entity.Property(e => e.WorkerName).HasMaxLength(100);
        });

        modelBuilder.Entity<Worker>(entity =>
        {
            entity.HasKey(e => e.WorkerId).HasName("PK__Workers__077C882671228180");

            entity.Property(e => e.WorkerId).ValueGeneratedNever();
            entity.Property(e => e.AverageRating)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(3, 2)");
            entity.Property(e => e.ExperienceYears).HasDefaultValue(0);
            entity.Property(e => e.IsAvailable).HasDefaultValue(true);
            entity.Property(e => e.TotalReviews).HasDefaultValue(0);

            entity.HasOne(d => d.WorkerNavigation).WithOne(p => p.Worker)
                .HasForeignKey<Worker>(d => d.WorkerId)
                .HasConstraintName("FK_Worker_User");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
