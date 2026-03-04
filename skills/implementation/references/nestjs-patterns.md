# NestJS Patterns Reference

Standard patterns and conventions for NestJS implementation within PM Copilot.

---

## Module Structure

```
src/
├── app.module.ts                 # Root module
├── main.ts                       # Bootstrap
├── common/                       # Shared utilities
│   ├── decorators/
│   ├── filters/
│   ├── guards/
│   ├── interceptors/
│   └── pipes/
└── modules/
    └── {feature}/
        ├── {feature}.module.ts
        ├── {feature}.controller.ts
        ├── {feature}.service.ts
        ├── dto/
        │   ├── create-{feature}.dto.ts
        │   └── update-{feature}.dto.ts
        ├── entities/
        │   └── {feature}.entity.ts
        └── {feature}.controller.spec.ts
```

---

## Controller Patterns

```typescript
@Controller('api/v1/{feature}')
export class FeatureController {
  constructor(private readonly featureService: FeatureService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateFeatureDto): Promise<FeatureResponseDto> {
    return this.featureService.create(dto);
  }

  @Get()
  findAll(@Query() query: PaginationDto): Promise<PaginatedResponse<FeatureResponseDto>> {
    return this.featureService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string): Promise<FeatureResponseDto> {
    return this.featureService.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateFeatureDto,
  ): Promise<FeatureResponseDto> {
    return this.featureService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.featureService.remove(id);
  }
}
```

---

## DTO Patterns (class-validator)

```typescript
export class CreateFeatureDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string;

  @IsEnum(FeatureStatus)
  @IsOptional()
  status?: FeatureStatus = FeatureStatus.ACTIVE;
}

export class UpdateFeatureDto extends PartialType(CreateFeatureDto) {}
```

---

## Service Patterns

```typescript
@Injectable()
export class FeatureService {
  constructor(
    @InjectRepository(Feature)
    private readonly featureRepo: Repository<Feature>,
  ) {}

  async create(dto: CreateFeatureDto): Promise<Feature> {
    const entity = this.featureRepo.create(dto);
    return this.featureRepo.save(entity);
  }

  async findOne(id: string): Promise<Feature> {
    const entity = await this.featureRepo.findOne({ where: { id } });
    if (!entity) {
      throw new NotFoundException(`Feature with ID "${id}" not found`);
    }
    return entity;
  }
}
```

---

## Entity Patterns (TypeORM)

```typescript
@Entity('features')
export class Feature {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ type: 'enum', enum: FeatureStatus, default: FeatureStatus.ACTIVE })
  status: FeatureStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.features)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
```

---

## Entity Patterns (Prisma)

When the project uses Prisma instead of TypeORM:
- Define models in `prisma/schema.prisma`
- Use `PrismaService` (extends `PrismaClient`) injected into services
- Use Prisma's generated types for DTOs where appropriate

---

## Exception Handling

Map spec error codes to NestJS exceptions:

| Spec Error | NestJS Exception |
|-----------|-----------------|
| 400 / INVALID_INPUT | `BadRequestException` |
| 401 / UNAUTHORIZED | `UnauthorizedException` |
| 403 / FORBIDDEN | `ForbiddenException` |
| 404 / NOT_FOUND | `NotFoundException` |
| 409 / CONFLICT | `ConflictException` |
| 429 / RATE_LIMIT | `ThrottlerException` (via @nestjs/throttler) |

---

## Guard Patterns

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) return true;
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}
```

---

## Global Setup (main.ts)

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  app.enableCors();

  await app.listen(3000);
}
bootstrap();
```

---

## Testing Patterns

```typescript
describe('FeatureService', () => {
  let service: FeatureService;
  let repo: Repository<Feature>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        FeatureService,
        {
          provide: getRepositoryToken(Feature),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
            find: jest.fn(),
            remove: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get(FeatureService);
    repo = module.get(getRepositoryToken(Feature));
  });

  it('should create a feature', async () => {
    const dto = { name: 'Test Feature' };
    const entity = { id: 'uuid', ...dto };
    jest.spyOn(repo, 'create').mockReturnValue(entity as Feature);
    jest.spyOn(repo, 'save').mockResolvedValue(entity as Feature);

    const result = await service.create(dto);
    expect(result).toEqual(entity);
  });
});
```
