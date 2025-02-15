﻿using Microsoft.EntityFrameworkCore;

namespace MEetAndYou.EFCoreEntities.Models
{
    public partial class MEetAndYouDBContext : DbContext
    {
        public MEetAndYouDBContext()
        {
        }

        public MEetAndYouDBContext(DbContextOptions<MEetAndYouDBContext> options)
            : base(options)
        {
        }

        public virtual DbSet<AdminAccountRecord> AdminAccountRecords { get; set; } = null!;
        public virtual DbSet<Category> Categories { get; set; } = null!;
        public virtual DbSet<Event> Events { get; set; } = null!;
        public virtual DbSet<EventLog> EventLogs { get; set; } = null!;
        public virtual DbSet<Itinerary> Itineraries { get; set; } = null!;
        public virtual DbSet<Role> Roles { get; set; } = null!;
        public virtual DbSet<UserAccountRecord> UserAccountRecords { get; set; } = null!;
        public virtual DbSet<UserToken> UserTokens { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseSqlServer("Data Source=DESKTOP-0QA4EN0\\SQLEXPRESS;Initial Catalog=MEetAndYou-DB;Integrated Security=True;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<AdminAccountRecord>(entity => {
                entity.HasKey(e => e.AdminId)
                    .HasName("PK__AdminAcc__719FE4E8D92D3466");

                entity.ToTable("AdminAccountRecords", "MEetAndYou");

                entity.Property(e => e.AdminId).HasColumnName("AdminID");

                entity.Property(e => e.AdminEmail)
                    .HasMaxLength(30)
                    .IsUnicode(false);

                entity.Property(e => e.AdminPassword)
                    .HasMaxLength(64)
                    .IsFixedLength();
            });

            modelBuilder.Entity<Category>(entity => {
                entity.HasKey(e => e.CategoryName)
                    .HasName("category_pk");

                entity.ToTable("Category", "MEetAndYou");

                entity.Property(e => e.CategoryName)
                    .HasMaxLength(50)
                    .IsUnicode(false)
                    .HasColumnName("categoryName");
            });

            modelBuilder.Entity<Event>(entity => {
                entity.ToTable("Events", "MEetAndYou");

                entity.Property(e => e.EventId).HasColumnName("eventID");

                entity.Property(e => e.Address)
                    .HasMaxLength(50)
                    .IsUnicode(false)
                    .HasColumnName("address");

                entity.Property(e => e.Description)
                    .HasMaxLength(350)
                    .IsUnicode(false)
                    .HasColumnName("description");

                entity.Property(e => e.EventDate)
                    .HasColumnType("datetime")
                    .HasColumnName("eventDate");

                entity.Property(e => e.EventName)
                    .HasMaxLength(35)
                    .IsUnicode(false)
                    .HasColumnName("eventName");

                entity.Property(e => e.Price).HasColumnName("price");

                entity.HasMany(d => d.CategoryNames)
                    .WithMany(p => p.Events)
                    .UsingEntity<Dictionary<string, object>>(
                        "EventCategory",
                        l => l.HasOne<Category>().WithMany().HasForeignKey("CategoryName").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("category_fk"),
                        r => r.HasOne<Event>().WithMany().HasForeignKey("EventId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("eventID_fk"),
                        j => {
                            j.HasKey("EventId", "CategoryName").HasName("eventCategory_pk");

                            j.ToTable("EventCategory", "MEetAndYou");

                            j.IndexerProperty<int>("EventId").HasColumnName("eventID");

                            j.IndexerProperty<string>("CategoryName").HasMaxLength(50).IsUnicode(false).HasColumnName("categoryName");
                        });
            });

            modelBuilder.Entity<EventLog>(entity => {
                entity.HasKey(e => e.LogId)
                    .HasName("PK__EventLog__5E548648459EF28B");

                entity.ToTable("EventLogs", "MEetAndYou");

                entity.Property(e => e.Category)
                    .HasMaxLength(15)
                    .IsUnicode(false);

                entity.Property(e => e.DateTime).HasColumnType("datetime");

                entity.Property(e => e.LogLevel)
                    .HasMaxLength(15)
                    .IsUnicode(false);

                entity.Property(e => e.Message)
                    .HasMaxLength(255)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<Itinerary>(entity => {
                entity.ToTable("Itinerary", "MEetAndYou");

                entity.Property(e => e.ItineraryId).HasColumnName("itineraryID");

                entity.Property(e => e.ItineraryName)
                    .HasMaxLength(35)
                    .IsUnicode(false)
                    .HasColumnName("itineraryName");

                entity.Property(e => e.ItineraryOwner).HasColumnName("itineraryOwner");

                entity.Property(e => e.Rating).HasColumnName("rating");

                entity.HasOne(d => d.ItineraryOwnerNavigation)
                    .WithMany(p => p.Itineraries)
                    .HasForeignKey(d => d.ItineraryOwner)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("itinOwner_fk");

                entity.HasMany(d => d.Users)
                    .WithMany(p => p.ItinerariesNavigation)
                    .UsingEntity<Dictionary<string, object>>(
                        "UserItinerary",
                        l => l.HasOne<UserAccountRecord>().WithMany().HasForeignKey("UserId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("userIDitinerary_fk"),
                        r => r.HasOne<Itinerary>().WithMany().HasForeignKey("ItineraryId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("itineraryID_fk"),
                        j => {
                            j.HasKey("ItineraryId", "UserId").HasName("userItinerary_pk");

                            j.ToTable("UserItinerary", "MEetAndYou");

                            j.IndexerProperty<int>("ItineraryId").HasColumnName("itineraryID");

                            j.IndexerProperty<int>("UserId").HasColumnName("UserID");
                        });
            });

            modelBuilder.Entity<Role>(entity => {
                entity.HasKey(e => e.Role1)
                    .HasName("PK__Roles__863D2149F085ACCF");

                entity.ToTable("Roles", "MEetAndYou");

                entity.Property(e => e.Role1)
                    .HasMaxLength(50)
                    .IsUnicode(false)
                    .HasColumnName("role");
            });

            modelBuilder.Entity<UserAccountRecord>(entity => {
                entity.HasKey(e => e.UserId)
                    .HasName("PK__UserAcco__1788CCAC0D4020A1");

                entity.ToTable("UserAccountRecords", "MEetAndYou");

                entity.Property(e => e.UserId).HasColumnName("UserID");

                entity.Property(e => e.UserEmail)
                    .HasMaxLength(30)
                    .IsUnicode(false);

                entity.Property(e => e.UserPassword)
                    .HasMaxLength(64)
                    .IsFixedLength();

                entity.Property(e => e.UserPhoneNum)
                    .HasMaxLength(15)
                    .IsUnicode(false);

                entity.Property(e => e.UserRegisterDate)
                    .HasMaxLength(30)
                    .IsUnicode(false);

                entity.HasMany(d => d.Roles)
                    .WithMany(p => p.Users)
                    .UsingEntity<Dictionary<string, object>>(
                        "UserRole",
                        l => l.HasOne<Role>().WithMany().HasForeignKey("Role").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("FK__UserRole__role__0F2D40CE"),
                        r => r.HasOne<UserAccountRecord>().WithMany().HasForeignKey("UserId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("FK__UserRole__UserID__0E391C95"),
                        j => {
                            j.HasKey("UserId", "Role").HasName("user_rolePK");

                            j.ToTable("UserRole", "MEetAndYou");

                            j.IndexerProperty<int>("UserId").HasColumnName("UserID");

                            j.IndexerProperty<string>("Role").HasMaxLength(50).IsUnicode(false).HasColumnName("role");
                        });
            });

            modelBuilder.Entity<UserToken>(entity => {
                entity.HasKey(e => new { e.UserId, e.Token })
                    .HasName("userRole_PK");

                entity.ToTable("UserToken", "MEetAndYou");

                entity.Property(e => e.UserId).HasColumnName("UserID");

                entity.Property(e => e.Token)
                    .HasMaxLength(64)
                    .HasColumnName("token")
                    .IsFixedLength();

                entity.Property(e => e.DateCreated)
                    .HasMaxLength(30)
                    .IsUnicode(false)
                    .HasColumnName("dateCreated");

                entity.Property(e => e.Salt).HasColumnName("salt");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.UserTokens)
                    .HasForeignKey(d => d.UserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("userID_fk");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
