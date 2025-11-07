# Data Model - [Feature Name]

> **Feature**: [Feature Number] - [Short Feature Name]  
> **Status**: Planning  
> **Created**: [Date]  
> **Last Updated**: [Date]

---

## Overview

This document defines the data model for the [Feature Name] feature, including database schema, entity relationships, and domain models.

**Database**: PostgreSQL 16

---

## Entity Relationship Diagram

```mermaid
erDiagram
    [ENTITY_NAME] ||--o{ [RELATED_ENTITY] : "has many"
    [ENTITY_NAME] }o--|| users : "belongs to"
    
    [ENTITY_NAME] {
        uuid id PK
        string name
        text description
        string status
        timestamp created_at
        timestamp updated_at
        uuid user_id FK
    }
    
    [RELATED_ENTITY] {
        uuid id PK
        uuid entity_id FK
        string property
        timestamp created_at
    }
    
    users {
        uuid id PK
        string email
        string name
    }
```

---

## Entities

### 1. [Entity Name]

**Table Name**: `[table_name]` (snake_case)

**Description**: [Brief description of what this entity represents]

**Relationships**:
- Belongs to: `users` (many-to-one)
- Has many: `[related_entity]` (one-to-many)

#### Database Schema

```sql
CREATE TABLE [table_name] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    user_id UUID NOT NULL,
    
    -- Constraints
    CONSTRAINT fk_[table]_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_[table]_status 
        CHECK (status IN ('active', 'inactive', 'pending')),
    CONSTRAINT uq_[table]_name_user 
        UNIQUE (name, user_id)
);

-- Indexes
CREATE INDEX idx_[table]_user_id ON [table_name](user_id);
CREATE INDEX idx_[table]_status ON [table_name](status);
CREATE INDEX idx_[table]_created_at ON [table_name](created_at DESC);

-- Trigger for updated_at
CREATE TRIGGER update_[table]_updated_at
    BEFORE UPDATE ON [table_name]
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

#### Column Details

| Column | Type | Nullable | Default | Description | Validation |
|--------|------|----------|---------|-------------|------------|
| `id` | UUID | No | `gen_random_uuid()` | Primary key | - |
| `name` | VARCHAR(100) | No | - | Resource name | 1-100 chars, unique per user |
| `description` | TEXT | Yes | NULL | Resource description | Max 500 chars |
| `status` | VARCHAR(20) | No | `'active'` | Current status | Must be: active, inactive, pending |
| `created_at` | TIMESTAMP | No | `NOW()` | Creation timestamp | Auto-managed |
| `updated_at` | TIMESTAMP | No | `NOW()` | Last update timestamp | Auto-managed by trigger |
| `user_id` | UUID | No | - | Owner reference | Must exist in users table |

#### Constraints

**Primary Key**:
- `id` (UUID)

**Foreign Keys**:
- `user_id` → `users.id` (CASCADE on delete)

**Unique Constraints**:
- (`name`, `user_id`) - Resource name must be unique per user

**Check Constraints**:
- `status` must be one of: `active`, `inactive`, `pending`

**Indexes**:
- `idx_[table]_user_id` - For filtering by user
- `idx_[table]_status` - For filtering by status
- `idx_[table]_created_at` - For sorting by creation date (DESC)

#### C# Domain Model

**File**: `src/CPR.Domain/Entities/[EntityName].cs`

```csharp
namespace CPR.Domain.Entities;

/// <summary>
/// Represents a [entity description]
/// </summary>
public class [EntityName]
{
    /// <summary>
    /// Unique identifier
    /// </summary>
    public Guid Id { get; set; }
    
    /// <summary>
    /// Resource name (1-100 characters, unique per user)
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Resource description (optional, max 500 characters)
    /// </summary>
    public string? Description { get; set; }
    
    /// <summary>
    /// Current status: active, inactive, or pending
    /// </summary>
    public string Status { get; set; } = "active";
    
    /// <summary>
    /// Creation timestamp (UTC)
    /// </summary>
    public DateTime CreatedAt { get; set; }
    
    /// <summary>
    /// Last update timestamp (UTC)
    /// </summary>
    public DateTime UpdatedAt { get; set; }
    
    /// <summary>
    /// Owner user ID
    /// </summary>
    public Guid UserId { get; set; }
    
    // Navigation properties
    
    /// <summary>
    /// Owner user
    /// </summary>
    public User User { get; set; } = null!;
    
    /// <summary>
    /// Related entities
    /// </summary>
    public ICollection<[RelatedEntity]> [RelatedEntities] { get; set; } = new List<[RelatedEntity]>();
}
```

#### Entity Framework Configuration

**File**: `src/CPR.Infrastructure/Data/Configurations/[EntityName]Configuration.cs`

```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using CPR.Domain.Entities;

namespace CPR.Infrastructure.Data.Configurations;

public class [EntityName]Configuration : IEntityTypeConfiguration<[EntityName]>
{
    public void Configure(EntityTypeBuilder<[EntityName]> builder)
    {
        builder.ToTable("[table_name]");
        
        builder.HasKey(e => e.Id);
        
        builder.Property(e => e.Id)
            .HasColumnName("id")
            .ValueGeneratedOnAdd();
            
        builder.Property(e => e.Name)
            .HasColumnName("name")
            .HasMaxLength(100)
            .IsRequired();
            
        builder.Property(e => e.Description)
            .HasColumnName("description")
            .HasColumnType("text");
            
        builder.Property(e => e.Status)
            .HasColumnName("status")
            .HasMaxLength(20)
            .IsRequired()
            .HasDefaultValue("active");
            
        builder.Property(e => e.CreatedAt)
            .HasColumnName("created_at")
            .IsRequired();
            
        builder.Property(e => e.UpdatedAt)
            .HasColumnName("updated_at")
            .IsRequired();
            
        builder.Property(e => e.UserId)
            .HasColumnName("user_id")
            .IsRequired();
        
        // Relationships
        builder.HasOne(e => e.User)
            .WithMany()
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasMany(e => e.[RelatedEntities])
            .WithOne(r => r.[EntityName])
            .HasForeignKey(r => r.[EntityName]Id)
            .OnDelete(DeleteBehavior.Cascade);
        
        // Indexes
        builder.HasIndex(e => e.UserId)
            .HasDatabaseName("idx_[table]_user_id");
            
        builder.HasIndex(e => e.Status)
            .HasDatabaseName("idx_[table]_status");
            
        builder.HasIndex(e => e.CreatedAt)
            .HasDatabaseName("idx_[table]_created_at")
            .IsDescending();
            
        // Unique constraint
        builder.HasIndex(e => new { e.Name, e.UserId })
            .HasDatabaseName("uq_[table]_name_user")
            .IsUnique();
    }
}
```

---

### 2. [Related Entity Name]

**Table Name**: `[related_table_name]` (snake_case)

**Description**: [Brief description]

**Relationships**:
- Belongs to: `[table_name]` (many-to-one)

[Repeat same structure as above for related entities]

---

## Database Migrations

### Migration: Add[FeatureName]Tables

**File**: `src/CPR.Infrastructure/Data/Migrations/[Timestamp]_Add[FeatureName]Tables.cs`

**Up Migration**:
```csharp
using Microsoft.EntityFrameworkCore.Migrations;

public partial class Add[FeatureName]Tables : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "[table_name]",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                description = table.Column<string>(type: "text", nullable: true),
                status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "active"),
                created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()"),
                updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()"),
                user_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_[table_name]", x => x.id);
                table.ForeignKey(
                    name: "fk_[table]_user",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.CheckConstraint(
                    "chk_[table]_status",
                    "status IN ('active', 'inactive', 'pending')");
            });

        migrationBuilder.CreateIndex(
            name: "idx_[table]_user_id",
            table: "[table_name]",
            column: "user_id");

        migrationBuilder.CreateIndex(
            name: "idx_[table]_status",
            table: "[table_name]",
            column: "status");

        migrationBuilder.CreateIndex(
            name: "idx_[table]_created_at",
            table: "[table_name]",
            column: "created_at",
            descending: true);

        migrationBuilder.CreateIndex(
            name: "uq_[table]_name_user",
            table: "[table_name]",
            columns: new[] { "name", "user_id" },
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "[table_name]");
    }
}
```

**Commands**:
```bash
# Create migration
dotnet ef migrations add Add[FeatureName]Tables --project src/CPR.Infrastructure --startup-project src/CPR.Api

# Apply migration
dotnet ef database update --project src/CPR.Infrastructure --startup-project src/CPR.Api

# Rollback migration
dotnet ef database update [PreviousMigrationName] --project src/CPR.Infrastructure --startup-project src/CPR.Api
```

---

## Data Access Patterns

### Repository Interface

**File**: `src/CPR.Application/Interfaces/Repositories/I[EntityName]Repository.cs`

```csharp
using CPR.Domain.Entities;

namespace CPR.Application.Interfaces.Repositories;

public interface I[EntityName]Repository
{
    Task<[EntityName]?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<[EntityName]>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<(IEnumerable<[EntityName]> Items, int TotalCount)> GetPagedAsync(
        Guid userId, 
        int page, 
        int pageSize, 
        string? sortBy = null, 
        string? sortOrder = null,
        string? status = null,
        string? search = null,
        CancellationToken cancellationToken = default);
    Task<[EntityName]> CreateAsync([EntityName] entity, CancellationToken cancellationToken = default);
    Task<[EntityName]> UpdateAsync([EntityName] entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> NameExistsForUserAsync(string name, Guid userId, Guid? excludeId = null, CancellationToken cancellationToken = default);
}
```

### Repository Implementation

**File**: `src/CPR.Infrastructure/Repositories/Implementations/[EntityName]Repository.cs`

```csharp
using CPR.Application.Interfaces.Repositories;
using CPR.Domain.Entities;
using CPR.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace CPR.Infrastructure.Repositories.Implementations;

public class [EntityName]Repository : I[EntityName]Repository
{
    private readonly ApplicationDbContext _context;

    public [EntityName]Repository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<[EntityName]?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.[EntityName]s
            .Include(e => e.[RelatedEntities])
            .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
    }

    public async Task<(IEnumerable<[EntityName]> Items, int TotalCount)> GetPagedAsync(
        Guid userId, 
        int page, 
        int pageSize, 
        string? sortBy = null, 
        string? sortOrder = null,
        string? status = null,
        string? search = null,
        CancellationToken cancellationToken = default)
    {
        var query = _context.[EntityName]s.Where(e => e.UserId == userId);

        // Filtering
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(e => e.Status == status);

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(e => e.Name.Contains(search) || (e.Description != null && e.Description.Contains(search)));

        // Sorting
        query = (sortBy?.ToLower(), sortOrder?.ToLower()) switch
        {
            ("name", "desc") => query.OrderByDescending(e => e.Name),
            ("name", _) => query.OrderBy(e => e.Name),
            ("status", "desc") => query.OrderByDescending(e => e.Status),
            ("status", _) => query.OrderBy(e => e.Status),
            ("created_at", "asc") => query.OrderBy(e => e.CreatedAt),
            _ => query.OrderByDescending(e => e.CreatedAt)
        };

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    // ... other methods
}
```

---

## Data Validation Rules

### Business Rules

1. **Unique Names Per User**
   - Each user must have unique resource names
   - Enforced by: Database unique constraint + application validation
   - Error: 409 Conflict

2. **Status Transitions**
   - Valid transitions: [Define state machine]
   - Example: `active` → `inactive` → `active` (allowed)
   - Example: `deleted` → `active` (not allowed)

3. **Cascade Delete**
   - When user is deleted, all their resources are deleted
   - When resource is deleted, all related entities are deleted

### Field Validation

| Field | Rules | Error Messages |
|-------|-------|---------------|
| `name` | Required, 1-100 chars | "Name is required and must be 1-100 characters" |
| `description` | Optional, max 500 chars | "Description must not exceed 500 characters" |
| `status` | Required, enum | "Status must be one of: active, inactive, pending" |
| `user_id` | Required, must exist | "Invalid user reference" |

---

## Performance Considerations

### Query Optimization

**Most Common Queries**:
1. List resources by user (filtered, sorted, paginated)
2. Get single resource by ID
3. Check name uniqueness

**Index Strategy**:
- `idx_[table]_user_id` - Covers most queries (filter by user)
- `idx_[table]_status` - For status filtering
- `idx_[table]_created_at DESC` - For sorting by date
- `uq_[table]_name_user` - For uniqueness check and name search

**Expected Query Performance**:
- List query: < 50ms (with index)
- Get by ID: < 10ms (primary key lookup)
- Name uniqueness check: < 10ms (unique index lookup)

### Scaling Considerations

- **Current**: Single table, expected < 100K rows per user
- **Future**: Consider partitioning by `user_id` if > 1M total rows
- **Caching**: Cache frequently accessed resources (TTL: 5-10 minutes)

---

## Seed Data

For development and testing purposes:

```csharp
public static class [EntityName]Seeder
{
    public static void Seed(ModelBuilder modelBuilder)
    {
        var userId = Guid.Parse("123e4567-e89b-12d3-a456-426614174000");
        
        modelBuilder.Entity<[EntityName]>().HasData(
            new [EntityName]
            {
                Id = Guid.Parse("550e8400-e29b-41d4-a716-446655440000"),
                Name = "Sample Resource 1",
                Description = "Sample description",
                Status = "active",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                UserId = userId
            }
        );
    }
}
```

---

## References

- Specification: `specifications/[####]-[feature-name]/description.md`
- Implementation Plan: `specifications/[####]-[feature-name]/implementation-plan.md`
- Endpoints: `specifications/[####]-[feature-name]/endpoints.md`
- Database Design Standards: `constitution.md` (Principle 11)

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| [Date] | [Name] | Initial data model created |
